package WWW::YoutubeViewer::PlaylistItems;

use utf8;
use 5.014;
use warnings;

=head1 NAME

WWW::YoutubeViewer::PlaylistItems - ...

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

    use WWW::YoutubeViewer;
    my $obj = WWW::YoutubeViewer->new(%opts);
    my $videos = $obj->videos_from_playlistID($playlist_id);

=head1 SUBROUTINES/METHODS

=cut

sub _make_playlistItems_url {
    my ($self, %opts) = @_;
    return
      $self->_make_feed_url(
                            'playlistItems',
                            pageToken => $self->page_token,
                            %opts
                           );
}

=head2 add_video_to_playlist($playlistID, $videoID; $position=1)

Add a video to given playlist ID, at position 1 (by default)

=cut

sub add_video_to_playlist {
    my ($self, $playlist_id, $video_id, $position) = @_;

    $playlist_id // return;
    $video_id    // return;
    $position //= 0;

    my $hash = {
                "snippet" => {
                              "playlistId" => $playlist_id,
                              "resourceId" => {
                                               "videoId" => $video_id,
                                               "kind"    => "youtube#video"
                                              },
                              "position" => $position,
                             }
               };

    my $url = $self->_make_playlistItems_url(pageToken => undef);
    $self->post_as_json($url, $hash);
}

=head2 favorite_video($videoID)

Favorite a video. Returns true on success.

=cut

sub favorite_video {
    my ($self, $video_id) = @_;
    $video_id // return;
    my $playlist_id = $self->get_playlist_id('favorites', mine => 'true');
    $self->add_video_to_playlist($playlist_id, $video_id);
}

=head2 videos_from_playlist_id($playlist_id)

Get videos from a specific playlistID.

=cut

sub videos_from_playlist_id {
    my ($self, $id) = @_;
    return $self->_get_results($self->_make_playlistItems_url(playlistId => $id, part => 'contentDetails,snippet'));
}

=head2 videos_from_id($playlist_id)

Get videos from a specific playlistID.

=cut

sub playlists_from_id {
    my ($self, $id) = @_;
    return $self->_get_results($self->_make_playlistItems_url(id => $id));
}

=head2 favorited_videos(;$username)

Get favorited videos for a given username or from the current user.

=cut

{
    no strict 'refs';
    foreach my $name (qw(favorites uploads likes)) {
        *{__PACKAGE__ . '::' . $name . '_from_username'} = sub {
            my ($self, $username) = @_;
            my $playlist_id = $self->get_playlist_id($name, $username ? (forUsername => $username) : (mine => 'true')) // return;
            $self->videos_from_playlist_id($playlist_id);
        };

        *{__PACKAGE__ . '::' . $name} = sub {
            my ($self, $channel_id) = @_;
            my $playlist_id =
              $self->get_playlist_id(
                                     $name, ($channel_id and $channel_id ne 'mine')
                                     ? (id => $channel_id)
                                     : (mine => 'true')
                                    ) // return;
            $self->videos_from_playlist_id($playlist_id);
        };
    }
}

=head1 AUTHOR

Trizen, C<< <trizenx at gmail.com> >>


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WWW::YoutubeViewer::PlaylistItems


=head1 LICENSE AND COPYRIGHT

Copyright 2013-2015 Trizen.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for more information.

=cut

1;    # End of WWW::YoutubeViewer::PlaylistItems
