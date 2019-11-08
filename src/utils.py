__author__ = 'luodong'

import codecs
import os.path
import platform
import stat
from hashlib import md5
import hashlib
import os
import os.path
import shutil
from pathlib import Path

def open_file(fullname, mode, encoding=None):
    if not os.path.exists(os.path.dirname(fullname)):
        os.makedirs(os.path.dirname(fullname), 0o777, True)

    if os.path.exists(fullname):
        os.chmod(fullname, stat.S_IWUSR | stat.S_IWGRP | stat.S_IWOTH | stat.S_IRUSR | stat.S_IRGRP | stat.S_IROTH)
    return codecs.open(fullname, mode, encoding)

def get_file_list_with_suffix(list_dir, suffix, bRelationPath = False,recursion = True, appendPath = ""):
    ret_list = []
    list_dir = Path(list_dir)
    # list_dir = os.path.normpath(list_dir).replace("\\", "/")
    file_list = os.listdir(list_dir)
    for i in range(len(file_list)):
        full_path = list_dir / file_list[i]
        if recursion and os.path.isdir(full_path):
            ret_list.extend(get_file_list_with_suffix(full_path, suffix, bRelationPath, recursion, full_path.relative_to(list_dir)))
        if file_list[i].endswith(suffix):
            if bRelationPath:
                ret_list.append(str((Path(appendPath) / file_list[i])))
            else:
                ret_list.append(str(full_path))
    return ret_list


def get_map_with_list(list):
    out_map = {}
    for i in range(len(list)):
        if list[i] not in out_map:
            out_map[list[i]] = list[i]
    return out_map


def copytree(src, dst, symlinks=False):
    names = os.listdir(src)
    if not os.path.isdir(dst):
        os.makedirs(dst)

    errors = []
    for name in names:
        srcname = os.path.join(src, name)
        dstname = os.path.join(dst, name)
        try:
            if symlinks and os.path.islink(srcname):
                linkto = os.readlink(srcname)
                os.symlink(linkto, dstname)
            elif os.path.isdir(srcname):
                copytree(srcname, dstname, symlinks)
            else:
                if os.path.isdir(dstname):
                    os.rmdir(dstname)
                elif os.path.isfile(dstname):
                    os.remove(dstname)
                shutil.copy2(srcname, dstname)
            # XXX What about devices, sockets etc.?
        except (IOError, os.error) as why:
            errors.append((srcname, dstname, str(why)))
        # catch the Error from the recursive copytree so that we can
        # continue with other files
        except OSError as err:
            errors.extend(err.args[0])
    try:
        shutil.copystat(src, dst)
    except WindowsError:
        # can't copy file access times on Windows
        pass
    except OSError as why:
        errors.extend((src, dst, str(why)))
    if errors:
        print(errors)


def get_python_fiel_Path(__file__):
    return os.path.normpath(os.path.split(os.path.realpath(__file__))[0])


def get_file_name_without_ext(full_path):
    return os.path.split(full_path)[1].split('.')[0]
import re
# re_map_int__int_checker = re.compile(r"^(\d*):(\d*)$",re.I)
# if __name__ == "__main__":
#     print(re_map_int__int_checker)


def print_error(msg):
    print('\033[1;31;40m')
    print(msg)
    print('\033[0m')
