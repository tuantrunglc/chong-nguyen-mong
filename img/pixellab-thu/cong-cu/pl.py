# Client nhỏ cho PixelLab MCP (HTTP). python3 pl.py <tool> '<json args>'  -> in phần text kết quả.
import json, os, sys, re, urllib.request
D = os.path.dirname(os.path.abspath(__file__))
def token():
    d = json.load(open(os.path.expanduser('~/.claude.json')))
    for p in d.get('projects', {}).values():
        s = p.get('mcpServers', {}).get('pixellab')
        if s: return s['headers']['Authorization']
def post(body, sid=None):
    h = {'Authorization': token(), 'Content-Type': 'application/json', 'Accept': 'application/json, text/event-stream'}
    if sid: h['Mcp-Session-Id'] = sid
    req = urllib.request.Request('https://api.pixellab.ai/mcp', json.dumps(body).encode(), h)
    with urllib.request.urlopen(req, timeout=300) as r:
        return r.headers.get('Mcp-Session-Id'), r.read().decode()
def session():
    f = os.path.join(D, 'sid2')
    if os.path.exists(f): return open(f).read().strip() or None
    sid, _ = post({'jsonrpc': '2.0', 'id': 1, 'method': 'initialize', 'params': {'protocolVersion': '2025-03-26', 'capabilities': {}, 'clientInfo': {'name': 'cc', 'version': '1'}}})
    post({'jsonrpc': '2.0', 'method': 'notifications/initialized'}, sid)
    open(f, 'w').write(sid or ''); return sid
def call(name, args):
    _, txt = post({'jsonrpc': '2.0', 'id': 2, 'method': 'tools/call', 'params': {'name': name, 'arguments': args}}, session())
    m = re.search(r'^data: (.*)$', txt, re.M)
    d = json.loads(m.group(1) if m else txt)
    if 'error' in d: return 'ERROR ' + json.dumps(d['error'])
    out = []
    for c in d['result']['content']:
        if c['type'] == 'text': out.append(c['text'])
        elif c['type'] == 'image': out.append('[image %s]' % c.get('mimeType'))
    return '\n'.join(out)
if __name__ == '__main__':
    print(call(sys.argv[1], json.loads(sys.argv[2])))
