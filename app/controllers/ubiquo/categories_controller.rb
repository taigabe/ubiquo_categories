class Ubiquo::CategoriesController < UbiquoController

  ubiquo_config_call :categories_access_control, {:context => :ubiquo_categories}
  before_filter :load_category_set
  before_filter :load_category, :only => [:show, :edit, :update, :destroy]

  # GET /categories
  # GET /categories.xml
  def index
    params[:order_by] ||= 'categories.name'
    params[:sort_order] ||= 'ASC'
    params[:per_page] ||= Ubiquo::Config.context(:ubiquo_categories).get(:categories_per_page)

    filters = {
      "filter_category_set" => params[:category_set_id],
      "per_page" => params[:per_page],
      "order_by" => params[:order_by],
      "sort_order" => params[:sort_order]
    }.merge(uhook_index_filters)

    @categories_pages, @categories = uhook_index_search_subject.paginated_filtered_search(params.merge(filters))

    respond_to do |format|
      format.html # index.html.erb
      format.js {
        render :js => @categories.to_json(:only => [:id,:name])
      }
      format.xml  {
        render :xml => @categories
      }
    end
  end

  # GET /categories/1
  # GET /categories/1.xml
  def show
    return if uhook_show_category(@category) == false

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @category }
    end
  end


  # GET /categories/new
  # GET /categories/new.xml
  def new
    @category = uhook_new_category

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @category }
    end
  end

  # GET /categories/1/edit
  def edit
    return if uhook_edit_category(@category) == false
  end

  # POST /categories
  # POST /categories.xml
  def create
    @category = uhook_create_category
    @category.category_set = @category_set

    respond_to do |format|
      if @category.save
        flash[:notice] = t("ubiquo.category.created")
        format.html { redirect_to(ubiquo_category_set_categories_url) }
        format.xml  { render :xml => @category, :status => :created, :location => @category }
      else
        flash[:error] = t("ubiquo.category.create_error")
        format.html { render :action => "new" }
        format.xml  { render :xml => @category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /categories/1
  # PUT /categories/1.xml
  def update
    respond_to do |format|
      if @category.update_attributes(params[:category])
        flash[:notice] = t("ubiquo.category.edited")
        format.html { redirect_to(ubiquo_category_set_categories_url) }
        format.xml  { head :ok }
      else
        flash[:error] = t("ubiquo.category.edit_error")
        format.html { render :action => "edit" }
        format.xml  { render :xml => @category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /categories/1
  # DELETE /categories/1.xml
  def destroy
    if uhook_destroy_category(@category)
      flash[:notice] = t("ubiquo.category.destroyed")
    else
      flash[:error] = t("ubiquo.category.destroy_error")
    end
    respond_to do |format|
      format.html { redirect_to(ubiquo_category_set_categories_url) }
      format.xml  { head :ok }
    end
  end

  protected

  def load_category_set
    @category_set = CategorySet.find(params[:category_set_id])
  end

  def load_category
    @category = Category.find(params[:id])
  end
end
