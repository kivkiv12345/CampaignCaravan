#!/usr/bin/env python3

from datetime import date
from os import path, system
from posixpath import dirname
from shutil import which
from subprocess import run, CalledProcessError

def check_gen_sidoc_version(version):
    try:
        p = run(["gen-sidoc", "--version"], capture_output=True)
        return p.returncode == 0 and p.stdout.decode() >= version
    except CalledProcessError:
        return False

def main():


    # Merely attempting to install dependecies takes a while,
    # even when they're already installed.
    # We there start by assuming that they are already installed.
    for _ in range(2):

        docdate = str(date.today())
        reports: dict[str, str] = {
            "Process Rapport": "procesrapport.rst",
            "Produkt Rapport": "produktrapport.rst",
        }
        
        for report_name, report_file in reports.items():
            report_name_escaped: str = report_name.replace(' ', '\ ')
            cmd_line = f"gen-sidoc -d {docdate} -t MAN {report_name_escaped} -o {report_name.replace(' ', '_')}.pdf {path.join(dirname(__file__).rstrip('.'), report_file).strip()}"
            print(cmd_line)
            err_code: int = system(cmd_line)
            if err_code != 0:
                break
        else:  # All documents generated successfully
            break  # No need to install dependencies


        extensions = [
            'sphinx_rtd_theme',
            'myst_parser',
            'sphinx_c_autodoc',
            "sphinx_design",
            "sphinx_git",
            "sphinx_copybutton"
        ]
        err_code: int = system(f"pip3 install {' '.join(i for i in extensions)}")
        assert err_code == 0

        if not which('gen-sidoc') or not check_gen_sidoc_version('0.1.6'):
            err_code: int = system("python3 -m pip install -U git+https://github.com/spaceinventor/libdoc.git")
            assert err_code == 0


if __name__ == '__main__':
    main()
