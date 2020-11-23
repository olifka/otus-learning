from re import findall
from os import listdir, system, popen
from io import open
from datetime import datetime


def get_pids():
    dirnames= []
    pids_list = []

    for name in listdir('/proc'):
        dirnames.append(name)

    for name in dirnames:
        pid = findall('[0-9]+', name)

        if len(pid) > 0:
            pids_list.append(int(pid[0]))

    return pids_list

pids_list = get_pids()

def get_cmd(pid):
    path = "/proc/{}/cmdline".format(pid)
    f = open(path, 'r')
    cmd = f.read()
    f.close()

    return cmd


def get_time(pid):
    now = datetime.now()
    current_year = now.year
    path = "/proc/{}".format(pid)
    bashCmd = "/bin/ls -ld {} > /tmp/pid_file_info".format(path)
    system(bashCmd)
    dt_start_str = popen("cat /tmp/pid_file_info|awk \'{ print $6\" \"$7\" \"$8 }\'").read()
    dt_start_str = "{} ".format(current_year) + dt_start_str.rstrip('\n')
    dt_start = datetime.strptime(dt_start_str.rstrip('\n'), "%Y %b %d %H:%M")

    delta = now - dt_start

    print(pid, dt_start, now, delta)

cmds = []


for pid in pids_list:
#     get_tty(pid)
#     get_stat(pid)
    get_time(pid)
    cmds.append(get_cmd(pid))

exit(0)
