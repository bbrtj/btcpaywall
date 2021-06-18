package Schema::Result::Account;

use header;
use base qw(DBIx::Class::Core);

__PACKAGE__->table("accounts");
__PACKAGE__->add_columns(qw(id account_index secret));
__PACKAGE__->set_primary_key("id");
__PACKAGE__->has_many(requests => "Schema::Result::Likes", "account_id");

