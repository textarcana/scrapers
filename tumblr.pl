# generate a batch file that will download images off a tumbleblog
# requires WGet and the LWP module
#
# For example, to download all the images on the first 5 pages of americarules.tumblr.com
#
#     perl tumblr.pl 5 americarules > temp.bat
#     temp.bat

$count=1;
while ($count <= $ARGV[0])
{
    print qq{lwp-request -o links http://$ARGV[1].tumblr.com/page/$count|grep jpg|perl -ne "m/IMG\\s+(.*)/; qx/wget \$1/"\n};
    ++$count;
}
