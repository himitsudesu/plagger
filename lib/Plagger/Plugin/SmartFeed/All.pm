package Plagger::Plugin::SmartFeed::All;
use strict;
use base qw( Plagger::Plugin::SmartFeed );

sub rule_hook { 'smartfeed.entry' }

sub register {
    my($self, $context) = @_;
    $context->register_hook(
        $self,
        'smartfeed.init'  => \&feed_init,
        'smartfeed.entry' => \&feed_entry,
        'smartfeed.finalize' => \&feed_finalize,
    );
}

sub feed_init {
    my($self, $context, $args) = @_;

    my $feed = Plagger::Feed->new;
    $feed->type('smartfeed');
    $feed->id( $self->conf->{id} || ('smartfeed:all') );
    $feed->title( $self->conf->{title} || "All Entries " );

    $self->{feed} = $feed;
}

sub feed_entry {
    my($self, $context, $args) = @_;
    $self->{feed}->add_entry($args->{entry}->clone);
}

sub feed_finalize {
    my($self, $context, $args) = @_;

    # because it's "All" you have to dedupe the entries
    my(%seen, @delete);
    for my $entry ($self->{feed}->entries) {
        if ($seen{$entry->permalink}++) {
            push @delete, $entry;
        }
    }
    $self->{feed}->delete_entry($_) for @delete;
    $self->{feed}->sort_entries;

    $context->update->add($self->{feed}) if $self->{feed}->count;
}

1;
