#!/usr/bin/env python3


# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
__author__ = "Ahmad Zyoud"

import requests, sys
import json
import pandas as pd
import requests
from requests.adapters import HTTPAdapter, Retry

class AdvanceSearchMetadataFetching:
    def __init__(self, fileType, project=None, tax=None):
        self.project =project
        self.tax = tax
        self.fileType = fileType

    def fetching_taxonomy(self, tax):
        server = "https://rest.ensembl.org"
        s = 'id'
        ext = "/taxonomy/id/{}?simple=1".format(tax)
        r = requests.get(server + ext, headers={"Content-Type": "application/json"})
        if not r.ok:
            r.raise_for_status()
            sys.exit()
        data = json.loads(r.content)
        taxid = data['id']
        return taxid


    def public_metadata_fetch(self):
        if self.fileType.lower() in ['fastq', 'bam']:
            tax_id = self.tax
            if self.tax is not None:
                if tax_id.isdigit() == True:
                    tax_id = self.fetching_taxonomy(self.tax)
            if tax_id and self.project:
                ext = f"?result=read_run&query=tax_eq({tax_id})%20AND%20study_accession%3D%22{self.project}" \
                      f"%22&fields=run_accession%2C{self.fileType.lower()}_ftp%2Csample_accession&limit=0&format=json"
            elif tax_id and not self.project:
                ext = f"?result=read_run&query=tax_eq({tax_id})&fields=run_accession%2C{self.fileType.lower()}" \
                      f"_ftp%2Csample_accession&limit=0&format=json"
            elif self.project and not tax_id:
                ext = f"?result=read_run&query=study_accession%3D%22{self.project}%22&fields=run_accession%2C" \
                      f"{self.fileType.lower()}_ftp%2Csample_accession&limit=0&format=json"
            print(ext)
            sys.stderr.write(
                'Fetching  Metadata From Advanced Search..............................................................')
            server = "https://www.ebi.ac.uk/ena/portal/api/search"
            session = requests.Session()
            retries = Retry(total=5, backoff_factor=1, status_forcelist=[502, 503, 504])
            session.mount('http://', HTTPAdapter(max_retries=retries))
            command = session.get(server + ext, headers={"Content-Type": "application/json"},
                                  stream=True)
            status = command.status_code
            if status == 204:
                sys.stderr.write(
                    f"Attention: No results matching your query parameters were found\nExiting.......")
                exit(1)
            if status == 500:
                sys.stderr.write("Attention: Internal Server Error, the process has stopped and skipped "
                                 "( Data might be incomplete )\n")
            data = json.loads(command.content)

            metadata = [{'run_accession': x['run_accession'],'sample_accession':x['sample_accession'], f'{self.fileType.lower()}_ftp': x[f'{self.fileType.lower()}_ftp']} for x in data]
            metadata_df = pd.DataFrame(metadata)

            print(metadata_df)
            return metadata_df
        else:
            sys.stderr.write('File type is not allowed, please include only one of the following terms (fasta, bam)')
            exit(1)