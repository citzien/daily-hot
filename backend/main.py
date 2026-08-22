"""Daily Hot Backend - 热点聚合 + 早间播报内容源"""
import asyncio
from datetime import datetime
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import httpx
import feedparser
from apscheduler.schedulers.asyncio import AsyncIOScheduler

app = FastAPI(title='DailyHot API', version='1.1.0')
app.add_middleware(CORSMiddleware, allow_origins=['*'], allow_credentials=True, allow_methods=['*'], allow_headers=['*'])

cache = {'weibo': [], 'zhihu': [], 'github': [], 'ai_news': [], 'brief': None, 'last_update': None}
scheduler = AsyncIOScheduler()

# 早间播报：真实 RSS 内容源（已实测可用）
# 科技：IT之家 + 少数派；时政：人民网时政频道
BRIEF_SOURCES = {
    'tech': [
        {'name': 'IT之家', 'url': 'https://www.ithome.com/rss/'},
        {'name': '少数派', 'url': 'https://sspai.com/feed'},
    ],
    'politics': [
        {'name': '人民网时政', 'url': 'http://www.people.com.cn/rss/politics.xml'},
    ],
}
BRIEF_PER_SOURCE = 5  # 每个源取前 N 条标题


async def fetch_brief() -> None:
    """抓取 RSS 并生成播报稿（每个源失败自动跳过）"""
    brief = {'date': datetime.now().strftime('%Y年%m月%d日'), 'tech': [], 'politics': [], 'text': ''}
    async with httpx.AsyncClient(timeout=15, follow_redirects=True) as client:
        for category in ('tech', 'politics'):
            for src in BRIEF_SOURCES[category]:
                try:
                    resp = await client.get(src['url'])
                    if resp.status_code != 200 or not resp.content.strip().startswith((b'<?xml', b'<rss')):
                        print(f"SKIP {src['name']}: not valid RSS (status={resp.status_code})")
                        continue
                    parsed = feedparser.parse(resp.content)
                    items = parsed.entries[:BRIEF_PER_SOURCE]
                    for it in items:
                        title = (getattr(it, 'title', '') or '').strip()
                        if title:
                            brief[category].append({'title': title, 'source': src['name']})
                    print(f"OK {src['name']}: {len(items)} items")
                except Exception as e:
                    print(f"ERR {src['name']}: {e}")
    brief['text'] = compose_brief_text(brief)
    cache['brief'] = brief
    cache['last_update'] = datetime.now().isoformat()
    print(f"[{datetime.now().strftime('%H:%M:%S')}] Brief updated ({len(brief['tech'])} tech / {len(brief['politics'])} politics)")


def compose_brief_text(brief: dict) -> str:
    """把条目拼成一段适合 TTS 朗读的中文文本"""
    parts = [f"早上好，今天是{brief['date']}，为你播报科技与时政热点。", '科技方面：']
    for i, it in enumerate(brief['tech'], 1):
        parts.append(f"第{i}条，{it['source']}：{it['title']}。")
    parts.append('时政方面：')
    for i, it in enumerate(brief['politics'], 1):
        parts.append(f"第{i}条，{it['source']}：{it['title']}。")
    parts.append('以上就是今天的早间热点，祝你一天顺利。')
    return '\n'.join(parts)


def set_mock_data():
    """原有 mock 数据（保留）"""
    cache['weibo'] = [
        {'title': '国产大飞机 C919 商业载客突破100万人次', '热度': '1250万', 'hot': True},
        {'title': '工信部发布人工智能发展白皮书', '热度': '980万', 'hot': True},
        {'title': '华为发布鸿蒙 NEXT 开发者预览版', '热度': '856万', 'hot': False},
        {'title': '比亚迪第1000万辆新能源汽车下线', '热度': '720万', 'hot': False},
        {'title': '央行宣布降准0.5个百分点', '热度': '680万', 'hot': False},
    ]
    cache['zhihu'] = [
        {'title': '为什么 GPT-5 这么火', '热度': '85万', 'hot': True},
        {'title': '小米汽车交付超预期', '热度': '62万', 'hot': False},
    ]
    cache['ai_news'] = [
        {'name': 'Claude 4', 'desc': 'New model', 'source': 'Mock'},
        {'name': 'GPT-5', 'desc': 'Coming soon', 'source': 'Mock'},
    ]


async def fetch_all():
    set_mock_data()
    try:
        async with httpx.AsyncClient(timeout=30) as client:
            resp = await client.get('https://api.github.com/search/repositories', params={'q': 'stars:>1000', 'sort': 'stars', 'per_page': 10})
            if resp.status_code == 200:
                data = resp.json()
                cache['github'] = [{'name': i['full_name'], 'desc': i.get('description') or '', 'lang': i.get('language') or '', 'stars': i['stargazers_count'], 'forks': i['forks_count']} for i in data.get('items', [])[:10]]
                print(f"GitHub: {len(cache['github'])} items")
    except Exception as e:
        print(f'GitHub Error: {e}')
    try:
        async with httpx.AsyncClient(timeout=30) as client:
            resp = await client.get('https://huggingface.co/api/models', params={'sort': 'trending', 'limit': 8})
            if resp.status_code == 200:
                data = resp.json()
                cache['ai_news'] = [{'name': i.get('id', '').split('/')[-1], 'desc': i.get('pipeline_tag', '') or 'AI Model', 'source': 'HF'} for i in data[:8]]
                print(f"HuggingFace: {len(cache['ai_news'])} items")
    except Exception as e:
        print(f'HuggingFace Error: {e}')
    cache['last_update'] = datetime.now().isoformat()


@app.on_event('startup')
async def startup():
    set_mock_data()
    await fetch_all()
    await fetch_brief()
    scheduler.add_job(fetch_all, 'interval', hours=1)
    scheduler.add_job(fetch_brief, 'interval', hours=1)
    scheduler.start()


@app.on_event('shutdown')
async def shutdown():
    scheduler.shutdown()


@app.get('/')
async def root():
    return {'message': 'DailyHot API', 'version': '1.1.0'}


@app.get('/api/weibo')
async def get_weibo():
    return {'source': 'Weibo', 'data': cache['weibo']}


@app.get('/api/zhihu')
async def get_zhihu():
    return {'source': 'Zhihu', 'data': cache['zhihu']}


@app.get('/api/github')
async def get_github():
    return {'source': 'GitHub', 'data': cache['github']}


@app.get('/api/ai')
async def get_ai():
    return {'source': 'AI', 'data': cache['ai_news']}


@app.get('/api/brief')
async def get_brief():
    """早间播报内容源：返回结构化条目与可直接朗读的文本"""
    if cache['brief'] is None:
        await fetch_brief()
    return cache['brief']


@app.get('/api/all')
async def get_all():
    return {'weibo': cache['weibo'], 'zhihu': cache['zhihu'], 'github': cache['github'], 'ai': cache['ai_news'], 'brief': cache['brief'], 'last_update': cache['last_update']}


@app.post('/api/refresh')
async def refresh():
    await fetch_all()
    await fetch_brief()
    return {'status': 'ok'}


if __name__ == '__main__':
    import uvicorn
    uvicorn.run(app, host='0.0.0.0', port=8000)