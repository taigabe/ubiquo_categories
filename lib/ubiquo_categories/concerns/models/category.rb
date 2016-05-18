module UbiquoCategories::Concerns::Models::Category
  extend ActiveSupport::Concern

  included do
    belongs_to :category_set
    has_many :category_relations
    belongs_to :parent, :class_name => 'Category'
    has_many :children, :class_name => 'Category', :foreign_key => 'parent_id'

    before_destroy :reassign_category_relations

    validates_presence_of :name, :category_set

    named_scope :category_set, lambda {|value| {:conditions => {:category_set_id => value}}}

    filtered_search_scopes :text => [:name], :enable => [:category_set]
  end

  module ClassMethods
    #For backwards compatibility
    def filtered_search(filters = {}, options = {})
      new_filters = {}
      filters.each do |key, value|
        if key == :text
          new_filters["filter_text"] = value
        elsif key == :category_set
          new_filters["filter_category_set"] = value
        else
          new_filters[key] = value
        end
      end

      super new_filters, options
    end

    def alias_for_association association_name
      connection.table_alias_for "#{table_name}_#{association_name}"
    end
  end

  def to_s
    name
  end

  protected

  def reassign_category_relations
    uhook_reassign_category_relations
  end
end
