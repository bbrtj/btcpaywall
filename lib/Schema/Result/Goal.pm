package Schema::Result::Goal;

use header;
use base qw(DBIx::Class::Core);

__PACKAGE__->table("goals");
__PACKAGE__->add_columns(qw(id account_id hrid key_number title content));
__PACKAGE__->set_primary_key("id");
__PACKAGE__->belongs_to(account => "Schema::Result::Account", "account_id");

