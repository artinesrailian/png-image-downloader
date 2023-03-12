# PNG Image Downloader

## Description

The purpose of this script is to download the png files from static html content to an output where user provides.

## Arguments

- -h help
- -u URL: The URL to download the PNG images from (mandatory)
- -o output_directory: The directory to save the downloaded PNG images to (mandatory)
- -U username: The username for basic authentication (optional)
- -P password: The password for basic authentication (optional)

## Example usage

    ./png-image-downloader.sh -u <https://example.com> -o /path/to/output -U username -P password
