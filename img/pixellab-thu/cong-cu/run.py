# python3 run.py <ten_file> <tool> '<json>'  : tạo ảnh, chờ, tải PNG đầu tiên về dl/<ten_file>.png
import sys, json, re, time, urllib.request
from pl import call
name, tool, args = sys.argv[1], sys.argv[2], json.loads(sys.argv[3])
if tool == 'get':
    jid = args['job_id']
else:
    r = call(tool, args); print(r[:300])
    jid = re.search(r'job_id: (\S+)', r).group(1)
for _ in range(20):
    g = call('get_image', {'job_id': jid})
    if 'processing' not in g.split('\n')[0] and 'pending' not in g.split('\n')[0]: break
    call('wait_for_jobs', {})
urls = re.findall(r'download: (https://\S+)', g)
print(g[:500])
if urls:
    urllib.request.urlretrieve(urls[0], f'dl/{name}.png'); print('saved', name)
