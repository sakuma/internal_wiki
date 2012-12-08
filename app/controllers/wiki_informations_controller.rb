class WikiInformationsController < ApplicationController
  # GET /wiki_informations
  # GET /wiki_informations.json
  def index
    @wiki_informations = WikiInformation.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @wiki_informations }
    end
  end

  # GET /wiki_informations/1
  # GET /wiki_informations/1.json
  def show
    @wiki_information = WikiInformation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @wiki_information }
    end
  end

  # GET /wiki_informations/new
  # GET /wiki_informations/new.json
  def new
    @wiki_information = WikiInformation.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @wiki_information }
    end
  end

  # GET /wiki_informations/1/edit
  def edit
    @wiki_information = WikiInformation.find(params[:id])
  end

  # POST /wiki_informations
  # POST /wiki_informations.json
  def create
    @wiki_information = WikiInformation.new(params[:wiki_information])

    respond_to do |format|
      if @wiki_information.save
        format.html { redirect_to @wiki_information, notice: 'Wiki information was successfully created.' }
        format.json { render json: @wiki_information, status: :created, location: @wiki_information }
      else
        format.html { render action: "new" }
        format.json { render json: @wiki_information.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /wiki_informations/1
  # PUT /wiki_informations/1.json
  def update
    @wiki_information = WikiInformation.find(params[:id])

    respond_to do |format|
      if @wiki_information.update_attributes(params[:wiki_information])
        format.html { redirect_to @wiki_information, notice: 'Wiki information was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @wiki_information.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /wiki_informations/1
  # DELETE /wiki_informations/1.json
  def destroy
    @wiki_information = WikiInformation.find(params[:id])
    @wiki_information.destroy

    respond_to do |format|
      format.html { redirect_to wiki_informations_url }
      format.json { head :no_content }
    end
  end
end
