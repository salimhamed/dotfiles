# check which process is listening on particular port
listening_on_port() {
    sudo lsof -n -i:"${1}" | grep LISTEN
}

# check which process is listening on particular port
listening_on_ports() {
    sudo lsof | grep LISTEN
}

# ssh into ec2 instance using ssm
ssm() {
    aws ssm start-session --target "${1}"
}

# count lines of code (requires `brew install cloc`)
#
# Example:
#   count-lines-of-code https://github.com/salimhamed/dashboard.git
count_lines_of_code() {
    git clone --depth 1 "$1" /tmp/temp-linecount-repo &&
        printf "('/tmp/temp-linecount-repo' will be deleted automatically)\n\n\n" &&
        cloc /tmp/temp-linecount-repo &&
        rm -rf /tmp/temp-linecount-repo
}
