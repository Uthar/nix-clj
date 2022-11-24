
from http.client import HTTPSConnection
from typing import Optional
from subprocess import run
from os.path import isfile
from os import makedirs
import sqlite3

def parse_line (line: str):
    parts = line.split("/")
    version = parts[-2]
    artifact = parts[-3]
    group = parts[0:-3]
    return (group, artifact, version)

def nix_hash (jar):
    proc = run(["nix", "hash", "file", jar], capture_output=True)
    hash = proc.stdout.decode("utf-8")
    return hash

def fetch_jar (group, artifact, version):
    conn = HTTPSConnection("repo.maven.apache.org")
    jar = f"{artifact}-{version}.jar"
    url = f"/maven2/{'/'.join(group)}/{artifact}/{version}/{jar}"
    try:
        if not isfile(f"jars/{jar}"):
            conn.request("GET", url)
            res = conn.getresponse()
            with open(f"jars/{jar}", "wb") as f:
                f.write(res.read())
                print(url, res.getcode())
        else:
            print(f"Already got {jar}")
    except:
        print("FAIL", url)
        pass
    finally:
        conn.close()
        
def main ():
    makedirs("jars", exist_ok=True)
    con = sqlite3.connect("jars.db")
    db = con.cursor()
    db.execute("create table if not exists jars (groupId, artifactId, version, hash)")
    with open("jars.txt") as f:
        for line in f.readlines():
            if len(line) > 1:
                group, artifact, version = parse_line(line)
                group = ".".join(group)
                jar = f"jars/{artifact}-{version}.jar"
                fetch_jar(group, artifact, version)
                hash = nix_hash(jar)
                db.execute("insert into jars values (?,?,?,?)",
                           [group, artifact, version, hash])
    con.commit()
    con.close()


if __name__ == "__main__":
    main()
    
