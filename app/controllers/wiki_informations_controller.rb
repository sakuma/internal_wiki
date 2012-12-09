class WikiInformationsController < ApplicationController
  # GET /wiki_informations
  # GET /wiki_informations.json
  def index
    @wiki_informations = WikiInformation.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @wiki_infos }
    end
  end

  # GET /wiki_informations/1
  # GET /wiki_informations/1.json
  def show
    @wiki_info = WikiInformation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @wiki_info }
    end
  end

  # GET /wiki_informations/new
  # GET /wiki_informations/new.json
  def new
    @wiki_info = WikiInformation.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @wiki_info }
    end
  end

  # GET /wiki_informations/1/edit
  def edit
    @wiki_info = WikiInformation.find(params[:id])
  end

  # POST /wiki_informations
  # POST /wiki_informations.json
  def create
    @wiki_info = WikiInformation.new(params[:wiki_information])

    respond_to do |format|
      if @wiki_info.save
        format.html { redirect_to @wiki_info, notice: 'Wiki information was successfully created.' }
        format.json { render json: @wiki_info, status: :created, location: @wiki_information }
      else
        format.html { render action: "new" }
        format.json { render json: @wiki_info.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /wiki_informations/1
  # PUT /wiki_informations/1.json
  def update
    @wiki_info = WikiInformation.find(params[:id])

    respond_to do |format|
      if @wiki_info.update_attributes(params[:wiki_information])
        format.html { redirect_to wiki_information_path(@wiki_info), notice: 'Wiki information was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @wiki_info.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /wiki_informations/1
  # DELETE /wiki_informations/1.json
  def destroy
    @wiki_info = WikiInformation.find(params[:id])
    @wiki_info.destroy

    respond_to do |format|
      format.html { redirect_to wiki_informations_url }
      format.json { head :no_content }
    end
  end
end
