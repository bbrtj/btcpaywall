package Schema::Result::Request;

use header;
use base qw(DBIx::Class::Core);

__PACKAGE__->table("requests");
__PACKAGE__->add_columns(qw(id amount derivation_index status ts));
__PACKAGE__->set_primary_key("id");

