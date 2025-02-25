class BookingsController < ApplicationController
  # Do no uncomment the line below: if the user has not logged in when attempting to book a costume, they get redirected to the login page
  # skip_before_action :authenticate_user!

  before_action :set_costume, only: [:new, :create]

  def index
    @bookings = current_user.bookings
  end
  def create

    @booking = Booking.new(booking_params)
    @booking.costume = @costume
    @booking.user = current_user

    unless booking_params[:start_date].present? && booking_params[:end_date].present?
      flash.now[:alert] = "Please confirm your rental dates."
      render 'costumes/show', status: :unprocessable_entity
      return
    end

    if booking_overlap?(@costume.id, @booking.start_date, @booking.end_date)
      flash.now[:alert] = "The costume is already booked for the selected dates...try again!"
      render 'costumes/show', status: :unprocessable_entity
    elsif @booking.start_date < Date.today
      flash.now[:alert] = "You cannot book a costume for a past date...try again!"
      render 'costumes/show', status: :unprocessable_entity
    else
      if @booking.save

      else
        flash.now[:alert] = "Booking failed, please try again"
        render 'costumes/show', status: :unprocessable_entity
      end
    end
  end

  def show
    @booking = Booking.find(params[:id])
  end

  def destroy
    @booking = Booking.find(params[:id])
    @booking.destroy
    redirect_to users_index_path, status: :see_other
  end

  private

  def booking_params
    params.require(:booking).permit(:user, :costume, :start_date, :end_date)
  end

  def set_costume
    @costume = Costume.find(params[:costume_id])
  end

  def booking_overlap?(costume_id, start_date, end_date)
    existing_bookings = Booking.where(costume_id: costume_id)
    existing_bookings.any? do |existing_booking|
      (existing_booking.start_date < end_date) && (existing_booking.end_date > start_date)
    end
  end

end
