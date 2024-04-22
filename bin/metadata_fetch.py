#!/usr/bin/env python3

# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

__author__ = "Ahmad Zyoud"

import argparse
from advSearchMetadata import AdvanceSearchMetadataFetching

parser = argparse.ArgumentParser(prog='ena-pathogen-fetch.py', formatter_class=argparse.RawDescriptionHelpFormatter,
                                     epilog="""
        + ============================================================ +
        |              European Nucleotide Archive (ENA)                 |
        |              Part of the Local Data Hub service                |
        |             Tool to to fetch read data from ENA                |
        + =========================================================== +  """)

parser.add_argument('-p', '--project', help='Project ID', type=str, required=False)
parser.add_argument('-t', '--tax', help='Tax Id or scientific name', type=str, required=False)
parser.add_argument('-ft', '--fileType', help='raw read file type , fastq or bam', type=str, required=True)
parser.add_argument('-o', '--output', help='read files output directory', type=str, required=True)
args = parser.parse_args()



#############################
#                           #
#           MAIN            #
#############################

if __name__ == '__main__':
   # Get the ftp link for the read files
   metadata = AdvanceSearchMetadataFetching(args.fileType, args.project, args.tax).public_metadata_fetch()
# Downloading files
   #run_accessions = metadata[['run_accession']]
   reads = metadata.to_csv(f'{args.output}/reads_metadata.txt', sep =',', index=False)