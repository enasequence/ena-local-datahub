#!/usr/bin/env python3

# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

__author__ = "Ahmad Zyoud"

import argparse
import os,sys
import pandas as pd
from fetchReadFiles import FetchingReadFiles

parser = argparse.ArgumentParser(prog='ena-pathogen-fetch.py', formatter_class=argparse.RawDescriptionHelpFormatter,
                                     epilog="""
        + ============================================================ +
        |              European Nucleotide Archive (ENA)                 |
        |              Part of the Local Data Hub service                |
        |             Tool to to fetch read data from ENA                |
        + =========================================================== +  """)

parser.add_argument('-url', '--url', help='ftp download link', type=str, required=False)
parser.add_argument('-s', '--sample', help='Sample ID', type=str, required=True)
parser.add_argument('-r', '--run', help='run ID', type=str, required=True)
parser.add_argument('-i', '--ignore', help='ignore accession list', type=str, required=True)
parser.add_argument('-ft', '--fileType', help='raw read file type , fastq or bam', type=str, required=True)
parser.add_argument('-o', '--Filesoutput', help='read files output directory', type=str, required=True)
parser.add_argument('-log', '--Logsoutput', help='logs output directory', type=str, required=True)
args = parser.parse_args()



#############################
#                           #
#           MAIN            #
#############################

if __name__ == '__main__':
    if os.path.exists(args.ignore):
        ignore_list = pd.read_csv(args.ignore)
    else:
        ignore_list = pd.DataFrame(columns=['run_accession'])
    if not args.run in ignore_list['run_accession'].values:
        # Downloading files
        fetch_files = FetchingReadFiles(args.fileType, args.Filesoutput, args.run, args.sample,args.Logsoutput, args.url).fetching_readsFiles()

