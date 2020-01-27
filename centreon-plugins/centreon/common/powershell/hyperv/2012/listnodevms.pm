#
# Copyright 2020 Centreon (http://www.centreon.com/)
#
# Centreon is a full-fledged industry-strength solution that meets
# the needs in IT infrastructure and application monitoring for
# service performance.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

package centreon::common::powershell::hyperv::2012::listnodevms;

use strict;
use warnings;
use centreon::plugins::misc;

sub get_powershell {
    my (%options) = @_;

    my $ps = '
$culture = new-object "System.Globalization.CultureInfo" "en-us"    
[System.Threading.Thread]::CurrentThread.CurrentUICulture = $culture
$ProgressPreference = "SilentlyContinue"

Try {
    $ErrorActionPreference = "Stop"
    $vms = Get-VM

    Foreach ($vm in $vms) {
        $note = $vm.Notes -replace "\r",""
        $note = $note -replace "\n"," - "
        Write-Host "[name=" $vm.VMName "][state=" $vm.State "][status=" $vm.Status "][IsClustered=" $vm.IsClustered "][note=" $note "]"
    }
} Catch {
    Write-Host $Error[0].Exception
    exit 1
}

exit 0
';

    return $ps;
}


sub list {
    my ($self, %options) = @_;
    
    # Following output:
    #[name= XXXX1 ][state= Running ][status= Operating normally ][IsClustered= True ][note= ]
    #...
    
    foreach my $line (split /\n/, $options{stdout}) {
        next if ($line !~ /^\[name=(.*?)\]\[state=(.*?)\]\[status=(.*?)\]\[IsClustered=(.*?)\]\[note=(.*?)\]/);
        my ($name, $state, $status, $IsClustered, $note) = (
            centreon::plugins::misc::trim($1), centreon::plugins::misc::trim($2), 
            centreon::plugins::misc::trim($3), centreon::plugins::misc::trim($4), centreon::plugins::misc::trim($5)
        );

        $self->{output}->output_add(long_msg => "'" . $name . "' [state = $state, status = " . $status .  ']');
    }
}

sub disco_show {
    my ($self, %options) = @_;
    
    # Following output:
    #[name= XXXX1 ][state= Running ][status= Operating normally ][IsClustered= True ][note= ]
    #...
    
    foreach my $line (split /\n/, $options{stdout}) {
        next if ($line !~ /^\[name=(.*?)\]\[state=(.*?)\]\[status=(.*?)\]\[IsClustered=(.*?)\]\[note=(.*?)\]/);
        my ($name, $state, $status, $IsClustered, $note) = (
            centreon::plugins::misc::trim($1), centreon::plugins::misc::trim($2), 
            centreon::plugins::misc::trim($3), centreon::plugins::misc::trim($4), centreon::plugins::misc::trim($5)
        );

        $self->{output}->add_disco_entry(
            name => $name,
            state => $state,
            status => $status,
            is_clustered => $IsClustered,
            note => $note
        );
    }
}

1;

__END__

=head1 DESCRIPTION

Method to get hyper-v informations.

=cut
