# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  def new
    @user = User.new
  end

  def create
    @user = User.new(sign_up_params)
    unless @user.valid?
      flash.now[:alert] = @user.errors.full_messages
      render :new and return
    end
    session["devise.regist_data"] = {user: @user.attributes}
    session["devise.regist_data"][:user]["password"] = params[:user][:password]
    @identification = @user.build_identification
    render :new_identification
  end

  def create_identification
    @user = User.new(session["devise.regist_data"]["user"])
    params[:identification][:birthday] = birthday_join
    @identification = Identification.new(identification_params)
    unless @identification.valid?
      flash.now[:alert] = @identification.errors.full_messages
      render :new_identification and return
    end
    session["devise.ident_data"] = {identification: @identification.attributes}
    @address = @user.build_address
    render :new_address
  end

  def create_address
    @user = User.new(session["devise.regist_data"]["user"])
    @address = Address.new(address_params)
    unless @address.valid?
      flash.now[:alert] = @address.errors.full_messages
      render :new_address and return
    end
    @user.build_address(@address.attributes)
    @user.build_identification(session["devise.ident_data"]["identification"])
    @user.save
    session["devise.ident_data"]["identification"].clear
    session["devise.regist_data"]["user"].clear
    sign_in(:user, @user)

    PaymentSelected.create(user_id: current_user.id, card_selected: "0")
    
  end
  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  # def create
  #   super
  # end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

   protected

  def identification_params
    params.require(:identification).permit(:last_name, :first_name, :last_name_kana, :first_name_kana, :birthday)
  end

  def birthday_join
    date = params[:birthday]

    if date["birthday(1i)"].empty? || date["birthday(2i)"].empty? || date["birthday(3i)"].empty?
      return
    end

    params[:identification][:birthday] = Date.new date["birthday(1i)"].to_i,date["birthday(2i)"].to_i,date["birthday(3i)"].to_i
  end

  def address_params
    params.require(:address).permit(:postcode, :city, :block, :building, :phone_number, :prefecture_id, :last_name, :first_name, :last_name_kana, :first_name_kana)
  end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
