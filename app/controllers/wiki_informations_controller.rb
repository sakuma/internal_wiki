class WikiInformationsController < ApplicationController

  before_filter :find_wiki_info, :only => [:show, :edit, :update, :destroy]

  def index
    @wiki_informations = WikiInformation.all
  end

  def show
  end

  def new
    @wiki_info = WikiInformation.new
  end

  def edit
  end

  def create
    @wiki_info = WikiInformation.new(params[:wiki_information])

    if @wiki_info.save
      redirect_to @wiki_info, notice: 'Wiki information was successfully created.'
    else
      render :new
    end
  end

  def update
    if @wiki_info.update_attributes(params[:wiki_information])
      redirect_to wiki_information_path(@wiki_info), notice: 'Wiki information was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @wiki_info.destroy
    redirect_to wiki_informations_path
  end

  def find_wiki_info
    @wiki_info = WikiInformation.find(params[:id])
  end
end
