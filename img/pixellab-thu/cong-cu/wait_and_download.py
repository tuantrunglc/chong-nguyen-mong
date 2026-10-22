import sys, os, time, json, urllib.request

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.append(os.path.join(BASE_DIR, "cong-cu"))
from pl import call

jobs = {
    "right": "500bc3c0-1658-4696-8a84-8803e568683f",
    "left": "e33ee788-f7c2-4ffa-8c24-03be5e962cdf"
}

completed = {}

for attempt in range(40):
    for side, job_id in jobs.items():
        if side in completed:
            continue
        res_str = call("get_image", {"job_id": job_id})
        # parse status
        lines = res_str.strip().split("\n")
        status_line = lines[0] if lines else ""
        print(f"[{side}] {status_line}")
        if "completed" in status_line:
            # find download url
            for line in lines:
                if line.startswith("download: "):
                    url = line.split("download: ")[1].strip()
                    out_path = os.path.join(BASE_DIR, "cong-cu", f"inpaint_{side}.png")
                    urllib.request.urlretrieve(url, out_path)
                    print(f"-> Saved {out_path}")
                    completed[side] = out_path
                    break
    if len(completed) == len(jobs):
        print("All jobs completed!")
        break
    time.sleep(5)

