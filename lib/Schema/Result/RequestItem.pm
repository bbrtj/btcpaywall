package Schema::Result::RequestItem;

use header;
use base qw(DBIx::Class::Core);

__PACKAGE__->table("request_items");
__PACKAGE__->add_columns(id => { is_auto_increment => 1 });
__PACKAGE__->add_columns(qw(request_id item));
__PACKAGE__->set_primary_key("id");
__PACKAGE__->belongs_to(request => "Schema::Result::Request", "request_id");

