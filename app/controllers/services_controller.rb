class ServicesController < ApplicationController
  before_filter :require_admin

  # GET /services
  # GET /services.xml
  def index
    @services = Service.all(:order => "did_at DESC")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @services }
    end
  end

  # GET /services/new
  # GET /services/new.xml
  def new
    @service = Service.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @service }
    end
  end

  # POST /services
  # POST /services.xml
  def create
    failed = false
    params[:service][:done].each{ |member_id,one|
      unless one.to_i != 1
        params[:service][:hours][member_id] = Setting.first.workshare_hours_per_month
      end
    }
    params[:service][:hours].each{ |member_id,amt|
      next if amt.nil? or (amt.kind_of? String and amt.strip == "")
      task = params[:service][:task][member_id]
      did_at = Date.new(params[:service]["did_at(1i)"].to_i,params[:service]["did_at(2i)"].to_i,params[:service]["did_at(3i)"].to_i)
      service = Service.new({:member_id => member_id, :hours => amt, :task => task, 
                             :observed_by => current_member, :did_at => did_at})
      unless service.save
        failed = true
        break
      end
    }
    
    respond_to do |format|
      unless failed
        format.html { redirect_to(services_url, :notice => 'Service was successfully created.') }
        format.xml  { render :xml => @service, :status => :created, :location => @service }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @service.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /services/1
  # DELETE /services/1.xml
  def destroy
    @service = Service.find(params[:id])
    @service.destroy

    respond_to do |format|
      format.html { redirect_to(services_url) }
      format.xml  { head :ok }
    end
  end
end
