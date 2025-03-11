# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20200614235220) do

  create_table "api_keys", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "user_id"
    t.string   "platform",                                  null: false
    t.integer  "account_id"
    t.string   "api_dc"
    t.integer  "status",              limit: 1, default: 1, null: false
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.string   "encrypted_token"
    t.string   "encrypted_token_iv"
    t.string   "encrypted_secret"
    t.string   "encrypted_secret_iv"
    t.string   "encrypted_key"
    t.string   "encrypted_key_iv"
    t.index ["platform"], name: "index_api_keys_on_platform", using: :btree
    t.index ["user_id"], name: "index_api_keys_on_user_id", using: :btree
  end

  create_table "api_requests", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "user_id",                       null: false
    t.string   "request_url"
    t.integer  "response_status"
    t.text     "response_data",   limit: 65535
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "assistant_invites", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "member_user_id",       null: false
    t.string   "pen_name"
    t.string   "invitee_email",        null: false
    t.datetime "invite_sent_at"
    t.datetime "assistant_created_at"
    t.integer  "assistant_user_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.index ["invitee_email"], name: "index_assistant_invites_on_invitee_email", using: :btree
    t.index ["member_user_id"], name: "index_assistant_invites_on_member_user_id", using: :btree
  end

  create_table "assistant_payment_requests", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "users_assistant_id",                null: false
    t.integer  "pay_amount",                        null: false
    t.datetime "accepted_at"
    t.string   "stripe_subscription_id"
    t.integer  "subscription_plan_id"
    t.datetime "declined_at"
    t.datetime "agreement_cancelled_at"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "last_known_subscription_status"
    t.datetime "last_known_subscription_status_at"
    t.index ["users_assistant_id"], name: "idx_on_whatever", using: :btree
  end

  create_table "book_links", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "book_id"
    t.string  "website_name", null: false
    t.string  "link_url",     null: false
    t.string  "link_caption"
    t.index ["book_id"], name: "index_book_links_on_book_id", using: :btree
  end

  create_table "books", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "user_id"
    t.integer  "pen_name_id",                                                           null: false
    t.string   "title",                                                                 null: false
    t.string   "format"
    t.decimal  "price",                         precision: 7, scale: 2
    t.date     "launch_date"
    t.string   "cover_image_url"
    t.text     "blurb",           limit: 65535
    t.datetime "created_at",                                                            null: false
    t.datetime "updated_at",                                                            null: false
    t.string   "amazon_author"
    t.integer  "review_count"
    t.decimal  "avg_review",                    precision: 2, scale: 1
    t.date     "pub_date"
    t.integer  "book_rank"
    t.boolean  "deleted",                                               default: false, null: false
    t.index ["user_id", "deleted"], name: "index_books_on_user_id_and_deleted", using: :btree
    t.index ["user_id", "pen_name_id"], name: "index_books_on_user_id_and_pen_name_id", using: :btree
    t.index ["user_id", "updated_at"], name: "index_books_on_user_id_and_updated_at", using: :btree
  end

  create_table "campaigns", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "platform_id",                         null: false
    t.integer  "list_id",                             null: false
    t.date     "sent_on",                             null: false
    t.datetime "sent_at"
    t.string   "status"
    t.integer  "emails_sent",                         null: false
    t.decimal  "open_rate",   precision: 5, scale: 4
    t.decimal  "click_rate",  precision: 5, scale: 4
    t.string   "subject",                             null: false
    t.string   "name"
    t.string   "preview_url"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.index ["list_id", "platform_id"], name: "index_campaigns_on_list_id_and_platform_id", unique: true, using: :btree
    t.index ["list_id", "sent_on"], name: "index_campaigns_on_list_id_and_sent_on", using: :btree
  end

  create_table "connect_payments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "reservation_id",                                     null: false
    t.string   "charge_id",                                          null: false
    t.string   "destination_acct_id",                                null: false
    t.integer  "amount"
    t.string   "currency"
    t.string   "application_fee"
    t.string   "application"
    t.integer  "paid",                     limit: 1
    t.integer  "refunded",                 limit: 1, default: 0,     null: false
    t.string   "card_id"
    t.string   "last4"
    t.string   "funding"
    t.integer  "exp_month",                limit: 2
    t.integer  "exp_year"
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.integer  "stripe_payment_intent_id"
    t.integer  "application_fee_amount"
    t.boolean  "destination_charge",                 default: false, null: false
    t.index ["charge_id"], name: "index_connect_payments_on_charge_id", unique: true, using: :btree
    t.index ["reservation_id"], name: "index_connect_payments_on_reservation_id", using: :btree
    t.index ["stripe_payment_intent_id"], name: "index_connect_payments_on_stripe_payment_intent_id", using: :btree
  end

  create_table "connect_refunds", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "refund_id",                         null: false
    t.integer  "amount",                            null: false
    t.string   "balance_transaction"
    t.string   "charge_id",                         null: false
    t.string   "currency"
    t.text     "metadata",            limit: 65535
    t.string   "status"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.index ["charge_id"], name: "index_connect_refunds_on_charge_id", using: :btree
  end

  create_table "conversation_user_pen_names", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "conversation_id",     null: false
    t.integer  "receipt_id",          null: false
    t.integer  "receipt_pen_name_id", null: false
    t.integer  "sender_pen_name_id",  null: false
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.index ["conversation_id"], name: "index_conversation_user_pen_names_on_conversation_id", using: :btree
  end

  create_table "emails", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "user_id",       null: false
    t.string   "email_address", null: false
    t.string   "mailer",        null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["email_address", "mailer"], name: "index_emails_on_email_address_and_mailer", using: :btree
    t.index ["user_id", "email_address", "mailer"], name: "index_emails_on_user_id_and_email_address_and_mailer", using: :btree
    t.index ["user_id", "mailer", "created_at"], name: "index_emails_on_user_id_and_mailer_and_created_at", using: :btree
  end

  create_table "external_reservations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "list_id",                                  null: false
    t.string   "recorded_list_name"
    t.date     "date",                                     null: false
    t.string   "book_owner_name"
    t.string   "book_owner_email"
    t.string   "book_title"
    t.string   "book_link"
    t.string   "inv_type",             default: "mention", null: false
    t.datetime "campaigns_fetched_at"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.index ["list_id", "date"], name: "index_external_reservations_on_list_id_and_date", using: :btree
  end

  create_table "genres", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string  "genre",                             null: false
    t.string  "category"
    t.integer "search_only", limit: 1, default: 0, null: false
    t.index ["category"], name: "index_genres_on_category", using: :btree
    t.index ["genre"], name: "index_genres_on_genre", using: :btree
  end

  create_table "inventories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "list_id"
    t.string   "inv_type",                         null: false
    t.integer  "sunday",     limit: 1, default: 0, null: false
    t.integer  "monday",     limit: 1, default: 0, null: false
    t.integer  "tuesday",    limit: 1, default: 0, null: false
    t.integer  "wednesday",  limit: 1, default: 0, null: false
    t.integer  "thursday",   limit: 1, default: 0, null: false
    t.integer  "friday",     limit: 1, default: 0, null: false
    t.integer  "saturday",   limit: 1, default: 0, null: false
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.index ["list_id"], name: "index_inventories_on_list_id", using: :btree
  end

  create_table "list_ratings", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "user_id",              null: false
    t.integer  "list_id",              null: false
    t.integer  "rating",     limit: 2, null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.index ["user_id", "list_id"], name: "index_list_ratings_on_user_id_and_list_id", unique: true, using: :btree
  end

  create_table "list_subscriptions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "user_id",                null: false
    t.integer  "list_id",                null: false
    t.integer  "reservation_id"
    t.string   "email",                  null: false
    t.datetime "opt_in_at"
    t.datetime "opt_in_succeeded_at"
    t.datetime "opt_in_failed_at"
    t.string   "opt_in_failed_message"
    t.datetime "opt_out_at"
    t.datetime "opt_out_succeeded_at"
    t.datetime "opt_out_failed_at"
    t.string   "opt_out_failed_message"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.index ["user_id", "list_id"], name: "index_list_subscriptions_on_user_id_and_list_id", using: :btree
    t.index ["user_id", "opt_out_at"], name: "index_list_subscriptions_on_user_id_and_opt_out_at", using: :btree
  end

  create_table "lists", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "user_id"
    t.integer  "pen_name_id"
    t.integer  "api_key_id"
    t.string   "platform_id",                                                        null: false
    t.string   "platform",                                                           null: false
    t.integer  "status",               limit: 1,                         default: 0, null: false
    t.string   "name"
    t.string   "adopted_pen_name"
    t.integer  "active_member_count"
    t.decimal  "open_rate",                      precision: 5, scale: 4
    t.decimal  "click_rate",                     precision: 5, scale: 4
    t.date     "cutoff_date"
    t.integer  "mention_price"
    t.integer  "mention_is_swap_only", limit: 1,                         default: 0, null: false
    t.integer  "feature_price"
    t.integer  "feature_is_swap_only", limit: 1,                         default: 0, null: false
    t.integer  "solo_price"
    t.integer  "solo_is_swap_only",    limit: 1,                         default: 0, null: false
    t.datetime "last_refreshed_at"
    t.datetime "last_action_at"
    t.datetime "created_at",                                                         null: false
    t.datetime "updated_at",                                                         null: false
    t.integer  "sponsored_tier"
    t.index ["last_refreshed_at"], name: "index_lists_on_last_refreshed_at", using: :btree
    t.index ["sponsored_tier", "last_action_at"], name: "index_lists_on_sponsored_tier_and_last_action_at", using: :btree
    t.index ["status", "last_action_at"], name: "index_lists_on_status_and_last_action_at", using: :btree
    t.index ["user_id"], name: "index_lists_on_user_id", using: :btree
  end

  create_table "lists_genres", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "list_id",                        null: false
    t.integer "genre_id",                       null: false
    t.integer "primary",  limit: 1, default: 0, null: false
    t.index ["genre_id", "list_id"], name: "index_lists_genres_on_genre_id_and_list_id", unique: true, using: :btree
    t.index ["list_id", "genre_id"], name: "index_lists_genres_on_list_id_and_genre_id", unique: true, using: :btree
    t.index ["list_id", "primary"], name: "index_lists_genres_on_list_id_and_primary", using: :btree
  end

  create_table "mailboxer_conversation_opt_outs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string  "unsubscriber_type"
    t.integer "unsubscriber_id"
    t.integer "conversation_id"
    t.index ["conversation_id"], name: "index_mailboxer_conversation_opt_outs_on_conversation_id", using: :btree
    t.index ["unsubscriber_id", "unsubscriber_type"], name: "index_mailboxer_conversation_opt_outs_on_unsubscriber_id_type", using: :btree
  end

  create_table "mailboxer_conversations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "subject",    default: ""
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "mailboxer_notifications", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "type"
    t.text     "body",                 limit: 65535
    t.string   "subject",                            default: ""
    t.string   "sender_type"
    t.integer  "sender_id"
    t.integer  "conversation_id"
    t.boolean  "draft",                              default: false
    t.string   "notification_code"
    t.string   "notified_object_type"
    t.integer  "notified_object_id"
    t.string   "attachment"
    t.datetime "updated_at",                                         null: false
    t.datetime "created_at",                                         null: false
    t.boolean  "global",                             default: false
    t.datetime "expires"
    t.index ["conversation_id"], name: "index_mailboxer_notifications_on_conversation_id", using: :btree
    t.index ["notified_object_id", "notified_object_type"], name: "index_mailboxer_notifications_on_notified_object_id_and_type", using: :btree
    t.index ["notified_object_type", "notified_object_id"], name: "mailboxer_notifications_notified_object", using: :btree
    t.index ["sender_id", "sender_type"], name: "index_mailboxer_notifications_on_sender_id_and_sender_type", using: :btree
    t.index ["type"], name: "index_mailboxer_notifications_on_type", using: :btree
  end

  create_table "mailboxer_receipts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "receiver_type"
    t.integer  "receiver_id"
    t.integer  "notification_id",                            null: false
    t.boolean  "is_read",                    default: false
    t.boolean  "trashed",                    default: false
    t.boolean  "deleted",                    default: false
    t.string   "mailbox_type",    limit: 25
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.boolean  "is_delivered",               default: false
    t.string   "delivery_method"
    t.string   "message_id"
    t.index ["notification_id"], name: "index_mailboxer_receipts_on_notification_id", using: :btree
    t.index ["receiver_id", "receiver_type"], name: "index_mailboxer_receipts_on_receiver_id_and_receiver_type", using: :btree
  end

  create_table "one_day_inventories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "list_id"
    t.string   "source",               default: "automatic", null: false
    t.integer  "solo",       limit: 2, default: 0,           null: false
    t.integer  "feature",    limit: 2, default: 0,           null: false
    t.integer  "mention",    limit: 2, default: 0,           null: false
    t.date     "date",                                       null: false
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.index ["list_id", "date"], name: "index_one_day_inventories_on_list_id_and_date", unique: true, using: :btree
    t.index ["list_id"], name: "index_one_day_inventories_on_list_id", using: :btree
  end

  create_table "password_tokens", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "user_id",    null: false
    t.string   "token",      null: false
    t.datetime "expires_at", null: false
    t.index ["token"], name: "index_password_tokens_on_token", unique: true, using: :btree
  end

  create_table "pen_name_requests", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "requestor_id",      null: false
    t.integer  "pen_name_id",       null: false
    t.datetime "owner_notified_at"
    t.string   "owner_decision"
    t.datetime "owner_decided_at"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["requestor_id", "pen_name_id"], name: "index_pen_name_requests_on_requestor_id_and_pen_name_id", using: :btree
  end

  create_table "pen_names", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "user_id",                                      null: false
    t.string   "group_status"
    t.string   "author_profile_url"
    t.string   "author_name",                                  null: false
    t.string   "author_image"
    t.integer  "verified",           limit: 1, default: 0,     null: false
    t.integer  "promo_service_only", limit: 1, default: 0,     null: false
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.boolean  "deleted",                      default: false, null: false
    t.index ["author_name", "verified"], name: "index_pen_names_on_author_name_and_verified", using: :btree
    t.index ["user_id", "promo_service_only"], name: "index_pen_names_on_user_id_and_promo_service_only", using: :btree
  end

  create_table "promo_send_confirmations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "reservation_id",                               null: false
    t.string   "reservation_type",     default: "Reservation", null: false
    t.integer  "campaign_id"
    t.string   "campaign_preview_url"
    t.datetime "seller_confirmed_at"
    t.datetime "buyer_confirmed_at"
    t.index ["reservation_id"], name: "index_promo_send_confirmations_on_reservation_id", using: :btree
  end

  create_table "promos", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "uuid",       null: false
    t.integer  "book_id",    null: false
    t.string   "name"
    t.integer  "list_size",  null: false
    t.date     "date",       null: false
    t.string   "promo_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["book_id", "date"], name: "index_promos_on_book_id_and_date", using: :btree
    t.index ["book_id"], name: "index_promos_on_book_id", using: :btree
    t.index ["uuid"], name: "index_promos_on_uuid", unique: true, using: :btree
  end

  create_table "proxies", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "ip",         null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reservations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "list_id",                                                         null: false
    t.string   "recorded_list_name"
    t.integer  "book_id",                                                         null: false
    t.datetime "seller_notified_at"
    t.datetime "buyer_invoiced_at"
    t.datetime "seller_accepted_at"
    t.datetime "seller_declined_at"
    t.datetime "buyer_cancelled_at"
    t.datetime "seller_cancelled_at"
    t.text     "seller_cancelled_reason",               limit: 65535
    t.datetime "system_cancelled_at"
    t.string   "system_cancelled_reason"
    t.datetime "campaigns_fetched_at"
    t.datetime "confirmation_requested_at"
    t.datetime "refund_requested_at"
    t.datetime "dismissed_from_buyer_activity_feed_at"
    t.datetime "dismissed_from_buyer_sent_feed_at"
    t.string   "inv_type",                                                        null: false
    t.date     "date",                                                            null: false
    t.text     "message",                               limit: 65535
    t.text     "reply_message",                         limit: 65535
    t.integer  "price"
    t.integer  "premium"
    t.integer  "payment_offer",                         limit: 1,     default: 1, null: false
    t.integer  "swap_offer",                            limit: 1,     default: 0, null: false
    t.integer  "swap_offer_list_id"
    t.integer  "swap_offer_solo",                       limit: 1,     default: 0
    t.integer  "swap_offer_feature",                    limit: 1,     default: 0
    t.integer  "swap_offer_mention",                    limit: 1,     default: 0
    t.integer  "swap_reservation_id"
    t.datetime "created_at",                                                      null: false
    t.datetime "updated_at",                                                      null: false
    t.index ["book_id", "created_at"], name: "index_reservations_on_book_id_and_created_at", using: :btree
    t.index ["book_id", "list_id"], name: "index_reservations_on_book_id_and_list_id", using: :btree
    t.index ["list_id", "book_id"], name: "index_reservations_on_list_id_and_book_id", using: :btree
    t.index ["list_id", "date"], name: "index_reservations_on_list_id_and_date", using: :btree
    t.index ["list_id", "seller_accepted_at"], name: "index_reservations_on_list_id_and_seller_accepted_at", using: :btree
  end

  create_table "stripe_accounts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "user_id",                                   null: false
    t.string   "acct_id",                                   null: false
    t.string   "deferred_acct_email"
    t.string   "country"
    t.integer  "deleted",             limit: 1, default: 0, null: false
    t.string   "publishable_key"
    t.string   "refresh_token"
    t.string   "access_token"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.index ["acct_id"], name: "index_stripe_accounts_on_acct_id", unique: true, using: :btree
    t.index ["user_id"], name: "idx_stripe_accounts_on_user_id", using: :btree
  end

  create_table "stripe_card_errors", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "reservation_id"
    t.string   "token"
    t.string   "card"
    t.string   "charge"
    t.string   "message"
    t.string   "error_type"
    t.string   "error_code"
    t.string   "decline_code"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "stripe_customers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "user_id",                                             null: false
    t.integer  "destination_stripe_account_id"
    t.string   "default_source"
    t.string   "cus_id",                                              null: false
    t.string   "currency"
    t.string   "email"
    t.integer  "deleted",                       limit: 1, default: 0, null: false
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
  end

  create_table "stripe_payment_intents", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "reservation_id",         null: false
    t.string   "customer_id"
    t.integer  "amount"
    t.string   "currency"
    t.string   "intent_id",              null: false
    t.string   "payment_method"
    t.integer  "application_fee_amount"
    t.string   "return_url"
    t.string   "status",                 null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.index ["intent_id"], name: "index_stripe_payment_intents_on_intent_id", unique: true, using: :btree
    t.index ["reservation_id"], name: "index_stripe_payment_intents_on_reservation_id", using: :btree
  end

  create_table "stripe_requires_action_events", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "current_user_id"
    t.string   "stripe_object_id"
    t.text     "next_action",      limit: 65535
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  create_table "stripe_setup_intents", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id",        null: false
    t.string   "customer_id"
    t.string   "intent_id",      null: false
    t.string   "payment_method"
    t.string   "return_url"
    t.string   "status",         null: false
    t.string   "usage"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["intent_id"], name: "index_stripe_setup_intents_on_intent_id", unique: true, using: :btree
    t.index ["user_id"], name: "index_stripe_setup_intents_on_user_id", using: :btree
  end

  create_table "stripe_shared_customer_sources", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "stripe_shared_customer_id",                       null: false
    t.integer  "deleted",                   limit: 1, default: 0, null: false
    t.integer  "default",                   limit: 1
    t.string   "card_id",                                         null: false
    t.string   "last4"
    t.string   "cvc_check"
    t.integer  "exp_month",                 limit: 2
    t.integer  "exp_year"
    t.string   "brand"
    t.string   "funding"
    t.string   "country"
    t.string   "name"
    t.string   "address_line1"
    t.string   "address_line2"
    t.string   "address_city"
    t.string   "address_state"
    t.string   "address_zip"
    t.string   "address_zip_check"
    t.string   "address_country"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.index ["stripe_shared_customer_id"], name: "idx_193", using: :btree
  end

  create_table "stripe_shared_customers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "user_id",                             null: false
    t.string   "customer_id",                         null: false
    t.integer  "deleted",       limit: 1, default: 0, null: false
    t.string   "email_address"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.index ["customer_id"], name: "index_stripe_shared_customers_on_customer_id", using: :btree
    t.index ["user_id", "deleted"], name: "idx_active_customers", using: :btree
  end

  create_table "stripe_webhook_events", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.text     "data",       limit: 65535
    t.string   "event_type"
    t.string   "account"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "subscription_plans", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "name"
    t.string   "stripe_acct_id"
    t.string   "stripe_plan_id"
    t.string   "interval"
    t.string   "currency",       null: false
    t.integer  "amount",         null: false
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["amount"], name: "index_subscription_plans_on_amount", using: :btree
    t.index ["stripe_plan_id"], name: "index_subscription_plans_on_stripe_plan_id", using: :btree
  end

  create_table "user_events", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "user_id",      null: false
    t.string   "event",        null: false
    t.string   "event_detail"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["user_id", "event", "event_detail"], name: "index_user_events_on_user_id_and_event_and_event_detail", using: :btree
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "role",                      limit: 1,             null: false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "country"
    t.string   "email",                                           null: false
    t.datetime "email_verified_at"
    t.integer  "bookings_subscribed",       limit: 1, default: 1, null: false
    t.integer  "messages_subscribed",       limit: 1, default: 1
    t.integer  "confirmations_subscribed",  limit: 1, default: 1, null: false
    t.integer  "auto_subscribe_on_booking", limit: 1, default: 0, null: false
    t.string   "auto_subscribe_email"
    t.string   "password_digest",                                 null: false
    t.string   "session_token",                                   null: false
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.datetime "closed_at"
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["last_name", "first_name"], name: "index_users_on_last_name_and_first_name", using: :btree
    t.index ["role"], name: "index_users_on_role", using: :btree
    t.index ["session_token"], name: "index_users_on_session_token", unique: true, using: :btree
  end

  create_table "users_assistants", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "user_id",      null: false
    t.integer  "assistant_id", null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["assistant_id", "user_id"], name: "index_users_assistants_on_assistant_id_and_user_id", unique: true, using: :btree
    t.index ["user_id", "assistant_id"], name: "index_users_assistants_on_user_id_and_assistant_id", unique: true, using: :btree
  end

  create_table "users_pen_names", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "user_id",     null: false
    t.integer  "pen_name_id", null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["pen_name_id", "user_id"], name: "index_users_pen_names_on_pen_name_id_and_user_id", unique: true, using: :btree
    t.index ["user_id", "pen_name_id"], name: "index_users_pen_names_on_user_id_and_pen_name_id", unique: true, using: :btree
  end

  create_table "versions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "item_type",                     null: false
    t.integer  "item_id",                       null: false
    t.string   "event",                         null: false
    t.string   "whodunnit"
    t.text     "object",     limit: 4294967295
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree
  end

  add_foreign_key "api_keys", "users"
  add_foreign_key "book_links", "books"
  add_foreign_key "books", "users"
  add_foreign_key "inventories", "lists"
  add_foreign_key "lists", "users"
  add_foreign_key "mailboxer_conversation_opt_outs", "mailboxer_conversations", column: "conversation_id", name: "mb_opt_outs_on_conversations_id"
  add_foreign_key "mailboxer_notifications", "mailboxer_conversations", column: "conversation_id", name: "notifications_on_conversation_id"
  add_foreign_key "mailboxer_receipts", "mailboxer_notifications", column: "notification_id", name: "receipts_on_notification_id"
  add_foreign_key "one_day_inventories", "lists"
  add_foreign_key "promos", "books"
  add_foreign_key "stripe_payment_intents", "reservations"
  add_foreign_key "stripe_setup_intents", "users"
end
