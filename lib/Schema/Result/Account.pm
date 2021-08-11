package Schema::Result::Account;

use header;
use base qw(DBIx::Class::Core);

__PACKAGE__->table("accounts");
__PACKAGE__->add_columns(id => {is_auto_increment => 1});
__PACKAGE__->add_columns(qw(name account_index callback_uri secret));
__PACKAGE__->set_primary_key("id");
__PACKAGE__->has_many(requests => "Schema::Result::Likes", "account_id");

