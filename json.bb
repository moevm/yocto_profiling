SUMMARY = "JSON for Modern C++ library"
HOMEPAGE = "https://github.com/nlohmann/json"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE.MIT;md5=f969127d7b7ed0a8a63c2bbeae002588"

SRC_URI = "git://github.com/nlohmann/json.git;protocol=https"
SRC_URI += "file://changes.patch"

SRCREV = "master"

S = "${WORKDIR}/git"


