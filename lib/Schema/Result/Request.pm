package Schema::Result::Request;

use header;
use base qw(DBIx::Class::Core);

__PACKAGE__->table("requests");
__PACKAGE__->add_columns(id => {is_auto_increment => 1});
__PACKAGE__->add_columns(qw(account_id amount derivation_index status ts));
__PACKAGE__->set_primary_key("id");
__PACKAGE__->belongs_to(account => "Schema::Result::Account", "account_id");
__PACKAGE__->has_many(items => "Schema::Result::RequestItem", "request_id");

