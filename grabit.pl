#!/usr/local/bin/perl    -w
use strict;
use LWP::Simple;
use LWP::UserAgent;
use HTML::LinkExtor;
use URI::URL;
#MAIN----------------------------------------------------------------------------
#Extract info from the tags in these files:
my $tag_type;             #Extract info from this type of tag ONLY (ok to use | here)
my $local_directory;      #Save files here
my $extensions;           #Only save files with these extensions (ok to use | here)    
$extensions = &grab_what();  #Let the user choose what type of files to grab
                             #Need to prefix the sub with "&" here or perl thinks its a call to a prototype and gives a warning
$ARGV[0] = "c:/windows/desktop/list.txt";  #List of urls to search for files
$local_directory = "c:/windows/desktop/grabit/";  #Store grabbed files here
$tag_type = "a";  #Look in <A> tags for file URIs
#
die "\n*******************\n      ERROR\n*******************\nPlease create the directory:\n\n $local_directory\n\n" unless -d $local_directory; #unless local really is a directory...
# 
while (<>) { #Assume we are reading a file with one URL on each line
    chomp(my $url = $_);
    if ($url ne "") {
	grabit($_, $tag_type, $local_directory, $extensions);
	print $url . "\n";
	#print " ";  #delete urls from list file once they've been grabbed
    }
    
}
#GRABIT--------------------------------------------------------------------------
#Just a wrapper for grab_hyperlink
#makes it easier to call g-h iteratively
sub grabit {
    my ($url, $tag_type, $local_directory, $extensions) = @_;
   
    grab_hyperlinked($url, $tag_type, $local_directory, $extensions);
}
#GRAB_HYPERLINKED----------------------------------------------------------------
#Search the file at URL for tags of type TAG_TYPE and grab those targets that end with arbitrarily chosen EXTENSIONS
sub grab_hyperlinked {
    my ($url, $tag_type, $local_directory, $extensions) = @_;
    my @links = list_links($url, $tag_type);

    #@links = @links[0 .. 7];  #only get the first X images (or comment this out to get all)

    foreach my $image_uri (@links) {
	next if $image_uri eq "";
	if ($image_uri =~ m{.($extensions)$}io){  #Only save files with the specified extensions
	    my $image_name = $image_uri;
	    $image_name =~ s{.*/(.*)}{$1};
	    $image_name = smart_save($image_name, $local_directory);  #Don't overwrite files with same name (obviously, either this line should be commented out, or the one below it should be)
	    save_image($image_uri, $local_directory . $image_name);
	    #print $image_uri;
	}
	}
    }
#SMART SAVE------------------------------------------------------------------------------
#This script checks to see if the file FILE_NAME already exists in DIRECTORY
#and if so, adds an integer to the end of the file's name, before the extension
#ie, if there are 2 files named foo.bar, then the second one to be saved will be renamed foo-1.bar
#The RETURN VALUE is the new name of the file.
sub smart_save {
    my ($file_name, $directory) = @_;
    my $int = 0;
    my $ext = $file_name;

    while (-e $directory . $file_name) {
	$ext =~ s{[^.]*(.*)}{$1};       #extension of file_name
	$file_name =~ s{([^.]*).*}{$1}; #file_name minus exension
	while (-e $directory . $file_name . "-" . $int . $ext) {
	    $int++;
	}
	$file_name = $file_name . "-" . $int . $ext;  #returns foo-1.bar
    }
    return $file_name;
}


#SAVE IMAGE------------------------------------------------------------------------------
#This script will grab an image from a web page and save it locally
#file = 'http://localhost/libraries/images/oiltower/top_boom.jpg';   #This is the name of the image on the server
#my $download = 'c:\windows\desktop\grabbed.jpg';   #This is where the image will be saved locally
#save_image($file, $download);
sub save_image {  #copy web FILE to local DOWNLOAD location
    my ($file, $download) = @_;

    my $user_agent = LWP::UserAgent->new;
    my $request = HTTP::Request->new('GET', $file);  
    my $response = $user_agent->request ($request, $download);  
}  
#LIST LINKS---------------------------------------------------------------------
#Extract the URL information from all links on the page, filtering out links that do not go to GIFS or JPEGS
#Returns an array containing the full paths of each of the images
#This code is adapted from the HTML::LinkExtor docs
#my $temp = "c:/windows/desktop/grabit.temp";
#my $url = "http://localhost/lwp/pics.html";  # for instance
#my @links = list_links($url, $temp);
sub list_links {
    my ($url, $tag_type) = @_;
    my $user_agent = new LWP::UserAgent;
    #$user_agent->agent("MSIE/5.5 " . $user_agent->agent);
    # Set up a callback that collect image links
    my @images = ();    
#
    # Make the parser.  Unfortunately, we don't know the base yet
    # (it might be diffent from $url)
#        my $p = HTML::LinkExtor->new(\&callback);
    my $p = HTML::LinkExtor->new(
				 sub {
				     my($tag, %attributes) = @_;
				     return if $tag ne $tag_type ;  # we only look closer at the tags specified by TAG_TYPE
				     push(@images, values %attributes);
				 }
);
#
# Request document and parse it as it arrives
my $response = $user_agent->request(HTTP::Request->new(GET => $url),
    sub {$p->parse($_[0])});
#
# Expand all image URLs to absolute ones
my $base = $response->base;
@images = map { $_ = url($_, $base)->abs; } @images;
#
# Print them out
#print join("\n", @images), "\n";
return @images;
}

#******************************************************************************
#*                                                                            *
#*                       USER-QUERY FUNCTIONS:                                *
#*                                                                            *
#******************************************************************************

#GRAB WHAT?--------------------------------------------------------------------
#Let the user choose what type(s) of files to grab
sub grab_what(){
    my $option_id = 1;
    my $selection;
    my @extensions = qw(
			jpg|gif|mpg 
			wav|zip
			zip
			wav
                        mp3
			);
    print "Welcome to Grabit by Noah Sussman\n\n";
foreach my $ext (@extensions){
    print "$option_id) $ext\n";
    $option_id++;
}
    print "\nWhat type(s) of files would you like to grab?\n";
    chomp($selection = <STDIN>);
    die "You must enter a number corresponding to an option!!" unless ($extensions[$selection - 1] ne "");
    print "Extension set to \"$extensions[$selection - 1]\".\nGrabbing...\n";
    return  $extensions[$selection - 1];
}

##############################
##############################
##############################
##############################
##############################
##############################
##############################
##########END#################
##############################
##############################
##############################
##############################
##############################
##############################
##############################
