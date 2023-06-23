
from distutils.dir_util import copy_tree

import base64
import errno
import hashlib
import json
import logging
import os
import shutil
import subprocess
import sys
import tempfile
import zipfile

def build(src_dir, output_path, install_dependencies):
    with tempfile.TemporaryDirectory() as build_dir:
        copy_tree(src_dir, build_dir)
        if os.path.exists(os.path.join(src_dir, 'requirements.txt')):
            subprocess.run(
                [sys.executable,
                 '-m',
                 'pip',
                 'install',
                 '--ignore-installed',
                 '--target', build_dir,
                 '-r', os.path.join(build_dir, 'requirements.txt'),
                 *(['--no-deps'] if install_dependencies == 'false' else [])],
                 check=True,
                 stdout=subprocess.DEVNULL,
            )
        make_archive(build_dir, output_path)
        return output_path


def make_archive(src_dir, output_path):
    try:
        os.makedirs(os.path.dirname(output_path))
    except OSError as e:
        if e.errno == errno.EEXIST:
            pass
        else:
            raise

    with zipfile.ZipFile(output_path, 'w') as archive:
        for root, dirs, files in os.walk(src_dir):
            for file in files:
                if file.endswith('.pyc'):
                    break
                metadata = zipfile.ZipInfo(
                    os.path.join(root, file).replace(src_dir, '').lstrip(os.sep)
                )
                metadata.external_attr = 0o755 << 16
                with open(os.path.join(root, file), 'rb') as f:
                    data = f.read()
                archive.writestr(
                    metadata,
                    data
                )

def get_hash(output_path):
    '''
    Return base64 encoded sha256 hash of archive file
    '''
    with open(output_path, 'rb') as f:
        h = hashlib.sha256()
        h.update(f.read())
    return base64.standard_b64encode(h.digest()).decode('utf-8', 'strict')


if __name__ == '__main__':
    logging.basicConfig(level='DEBUG')
    query = json.loads(sys.stdin.read())
    logging.debug(query)
    archive = build(query['src_dir'], query['output_path'], query['install_dependencies'])
    print(json.dumps({'archive': archive, 'base64sha256':get_hash(archive)}))