class EntriesController < ApplicationController
  before_action :set_entry, only: [:show, :update, :destroy]
  before_action :set_user
  before_action :require_login
  before_action :require_authorization, except: [:create]
  before_action :require_custom_authorization, only: [:create]

  def index
    @all_user_entries = @user.entries.order(created_at: :desc)
    filter_entries(@all_user_entries)
    @monthly_entries = @all_user_entries.this_month
    @total_cards = @monthly_entries.total_cards
    @cards = Card.all
    @categories = Category.all.limit(7)
    @duplicate_cards_hash = @user.cards.select_duplicates
  end

  def show
    @thoughts = @entry.thoughts.order(created_at: :desc)
    @thought = @entry.thoughts.build
  end

  def new
    @entry = @user.entries.build
    @category = @entry.build_category
    @categories = Category.all.limit(5)
  end

  def create
    @entry = @user.entries.create(entry_params)
    params[:entry] && params[:entry][:card_ids] ? custom_entry_redirect(@entry) : regular_entry_redirect(@entry)
  end

  def update
    @entry = Entry.find_by(id: params[:entry_id]) if params[:entry_id].present?
    regular_entry_redirect(@entry)
  end

  def destroy
    @entry.destroy
    flash[:message] = "Reading successfully deleted"
    redirect_to user_entries_path(current_user)
  end

  private

  def require_custom_authorization
    unless @user == current_user || (User.find_by(id: params[:entry][:responder_id]) if params[:entry]) == current_user
      flash[:message] = "You do not have permission to view that page."
      redirect_to user_entries_path(current_user)
    end
  end

  def custom_entry_redirect(entry)
    if @entry.valid?
      redirect_to request_path(@entry.request)
    else
      @request = Request.find_by(id: params[:entry][:request_id])
      @cards = Card.all
      flash[:message] = @entry.errors.full_messages
      render "requests/show"
    end
  end

  def regular_entry_redirect(entry)
    if @entry.valid?
      @entry.add_randomized_card
      redirect_to(entry_path(@entry))
    else
      @category = @entry.build_category
      @categories = Category.all.limit(5)
      render :new 
    end
  end

  def filter_entries(all_entries)
    if params[:spread].present?
        @user_entries = @all_user_entries.filter_by_spread(params[:spread][:category_name])
    elsif params[:card].present?
        @user_entries = @all_user_entries.filter_by_card(params[:card][:card_id])
    else
        @user_entries = @all_user_entries 
    end    
  end

  def set_entry
    @entry = Entry.find_by(id: params[:id])
    if @entry.nil?
      flash[:message] = "The requested page does not exist"
      redirect_to user_entries_path(current_user)
    end
  end

  def set_user
    @user = User.find_by(id: params[:user_id]) || @entry.user
  end

  def entry_params
    params.require(:entry).permit(:request_id, :category_id, :interpretation_1, :interpretation_2, :interpretation_3, { card_ids: [] }, category_attributes: [:question_1, :question_2, :question_3])
  end
end