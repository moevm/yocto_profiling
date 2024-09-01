import requests
from urllib.parse import urljoin
from html.parser import HTMLParser

class DirectoryListingParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.links = []

    def handle_starttag(self, tag, attrs):
        if tag == 'a':
            for attr in attrs:
                if attr[0] == 'href':
                    self.links.append(attr[1])

def get_directory_listing(url):
    response = requests.get(url)
    if response.status_code == 200:
        return response.text
    else:
        raise Exception(f"Failed to retrieve directory listing: {response.status_code}")

def parse_directory_listing(html):
    parser = DirectoryListingParser()
    parser.feed(html)
    return parser.links

def create_index_file(base_url, index_file_path):
    with open(index_file_path, 'w') as index_file:
        def traverse_directory(url):
            html = get_directory_listing(url)
            links = parse_directory_listing(html)
            for link in links:
                full_url = urljoin(url, link)
                if link.endswith('/'):
                    traverse_directory(full_url)
                else:
                    index_file.write(f"File: {full_url}\n")

        traverse_directory(base_url)


if __name__ == '__main__':
    base_url = 'http://0.0.0.0:8888'
    index_file_path = './http_index_file.txt'

    create_index_file(base_url, index_file_path)
