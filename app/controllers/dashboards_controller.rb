class DashboardsController < ApplicationController
  
  before_action :require_current_member_user
  before_action :redirect_prohibited_users
  
  PROMOS_FOR_SEND_CONFIRMATION_AS_JSON = {
    :methods => [:id, :book_title, :book_author, :date_pretty, :refundable?]
  }

  PROMOS_FOR_FEEDS_AS_JSON = {
    :methods => [:id, :book_title, :book_author, :date_pretty, :internal],
    :include => {
      book: {
        only: [:user_id, :pen_name_id, :title],
        methods: [:author],
        include: {
          pen_name: {
            only: [:id, :author_name]
          }
        }
      }
    }
  }
  
  def show
    @today_in_local_timezone = Date.today_in_local_timezone.pretty_with_year
    @greeting = greeting
    @user = current_member_user.as_json(only: [:first_name])
    @lists = current_member_user.lists.status_active
             .includes(
               :pen_name,
               :payments, 
               :external_reservations_today, 
               reservations_today: {:book => :pen_name}, 
               reservations_pending: {:book => :pen_name})
             .as_json(
             	include: { 
                :pen_name => { only: [:id, :author_name]},
                :reservations_today => PROMOS_FOR_FEEDS_AS_JSON,
                :external_reservations_today => PROMOS_FOR_FEEDS_AS_JSON,
                :reservations_pending => PROMOS_FOR_FEEDS_AS_JSON 
              }, 
             	except: [:user_id],
             	methods: [:active_member_count_delimited, :total_dollars_paid])
    @books = current_member_user.books.as_json(only: [:id, :title])
    @prohibitive_refund_request = current_member_user.prohibitive_refund_request_reservation.presence
    @recent_book_promos = current_member_user.recent_book_promos_feed
                          .includes({swap_reservation: {book: :pen_name}}, {book: :pen_name}, {list: :pen_name}, :promo_send_confirmation, :connect_payments)
                          .as_json( 
                          	:methods => Reservation::METHODS_FOR_BUYER_ACTIVITY,
                            include: {
                              swap_reservation: { methods: [:date_pretty, :book_author] },
                              book: {
                                only: [],
                                include: {
                                  pen_name: {
                                    only: [:id, :author_name]
                                  }
                                }
                              },
                              list: {
                                only: [:user_id, :pen_name_id],
                                include: {
                                  pen_name: {
                                    only: [:id, :author_name]
                                  }
                                }
                              }
                            }
                          )
    @internal_promos_for_send_confirmation = current_member_user.reservations_for_send_confirmation.in_last_months(6).includes({book: :pen_name}, :connect_payments, :promo_send_confirmation).select(&:send_unconfirmed?)
    @external_promos_for_send_confirmation = current_member_user.external_reservations_for_send_confirmation.in_last_months(6).includes(:promo_send_confirmation).select(&:send_unconfirmed?)
    @promos_for_send_confirmation = (@internal_promos_for_send_confirmation + @external_promos_for_send_confirmation).sort_by(&:date).as_json(PROMOS_FOR_SEND_CONFIRMATION_AS_JSON)
    withFlash_component
  end
  
  def greeting
    if current_assistant_or_member_user.first_name.present?
      "Hi #{current_assistant_or_member_user.first_name}"
    else
      "Hello,"
    end
  end
  
end