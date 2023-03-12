#!/bin/bash

# Print the usage information for the script
if [[ $1 == "-h" || $1 == "--help" ]]; then
	echo "Usage: $0 -u URL -o output_directory [-U username] [-P password]"
	echo ""
	echo "Downloads PNG images from the specified URL to the specified output directory."
	echo ""
	echo "Options:"
	echo "  -u URL: The URL to download the PNG images from (mandatory)"
	echo "  -o output_directory: The directory to save the downloaded PNG images to (mandatory)"
	echo "  -U username: The username for basic authentication (optional)"
	echo "  -P password: The password for basic authentication (optional)"
	echo ""
	echo "Example usage:"
	echo "  $0 -u http://example.com -o /path/to/output"
	echo "  $0 -u http://example.com -o /path/to/output -U username -P password"
	exit 0
fi

# Initialize variables
url=""
output_dir=""
username=""
password=""
extracted_urls=()

# Parse command line arguments
while [[ $# -gt 0 ]]
do
	key="$1"
	case $key in
    	-U|--username)
        	username="$2"
        	shift 2
        	;;
    	-P|--password)
        	password="$2"
        	shift 2
        	;;
    	-o|--output)
        	output_dir="$2"
        	shift 2
        	;;
    	-u|--url)
        	url="$2"
        	shift 2
        	;;
    	*)
        	shift
        	;;
	esac
done

# Check if mandatory arguments are provided
if [[ -z "$url" || -z "$output_dir" ]]
then
	echo "ERROR: URL and output directory path are mandatory arguments"
	exit 1
fi

# Use curl to fetch the HTML content of the URL
if [[ -n "$username" && -n "$password" ]]
then
	content=$(curl --user "$username:$password" -L "$url")
else
	content=$(curl -L "$url")
fi

# Check if the HTTP request was successful
if [[ $? -ne 0 ]]
then
	echo "ERROR: Failed to fetch the HTML content of the URL"
	exit 1
fi

# Extract URLs of PNG images
extracted_urls=$(echo "$content" | grep -Eo '<img[^>]* src="([^"]*)"[^>]*>' | grep -Eo 'src="([^"]*)"' | cut -d'"' -f2 | grep -Ei '\.png$')

# Check if there are any PNG images to download
if [[ -z "$extracted_urls" ]]
then
	echo "WARNING: No PNG images found in the HTML content of the URL"
	exit 0
fi

# Create the output directory if it doesn't exist
if [[ ! -d "$output_dir" ]]
then
	mkdir -p "$output_dir"
	if [[ $? -ne 0 ]]
	then
    	echo "ERROR: Failed to create the output directory"
    	exit 1
	fi
fi

# Download PNG images to the output directory
for extracted_url in $extracted_urls
do
	filename=$(basename "$extracted_url")
	url_with_protocol=$(echo "$extracted_url" | sed -e 's/^\/\//https:\/\//')
	curl --create-dirs -L "$url_with_protocol" -o "$output_dir/$filename"
	if [[ $? -ne 0 ]]
	then
    	echo "ERROR: Failed to download the PNG image: $extracted_url"
	fi
done

echo "INFO: Finished downloading PNG images to the output directory: $output_dir"
