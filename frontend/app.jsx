require("./ext/String");
import React from "react";
import ReactDOM from "react-dom";

import LandingPage from "./components/landing/LandingPage";
import CreateAccountPage from "./components/create_account/CreateAccountPage";
import MyListsPage from "./components/my_lists/MyListsPage";
import IntegrationsPage from "./components/integrations/IntegrationsPage";
import DashboardAppWithFlash from "./components/dashboard/DashboardAppWithFlash";
import SignInPage from "./components/sign_in/SignInPage";
import MarketplacePageWithFlash from "./components/marketplace/MarketplacePageWithFlash";
import BookingCalendarPage from "./components/booking_calendar/BookingCalendarPage";
import MyBooksPageWithFlash from "./components/my_books/MyBooksPageWithFlash";
import LaunchPageAppWithFlash from "./components/launches/LaunchPageAppWithFlash";
import ClientsPage from "./components/clients/ClientsPage";
import AssistantPaymentRequestAcceptPage from "./components/assistant_payment_requests/AssistantPaymentRequestAcceptPage";
import ConfirmPromosAppWithFlash from "./components/confirm_promos/ConfirmPromosAppWithFlash";
import ResetPassword from "./components/reset_password/ResetPassword";
import EmailVerifier from "./components/EmailVerifier";
import PaymentInfoPage from "./components/payment_info/PaymentInfoPage";
import PenNamesAppWithFlash from "./components/pen_names/PenNamesAppWithFlash";
import ReservationPage from "./components/reservations/ReservationPage";
import CalendarPage from "./components/calendars/CalendarPage";
import ProfilePage from "./components/profile/ProfilePage";
import TermsOfService from "./components/TermsOfService";
import ConversationsTable from "./components/messages/ConversationsTable";
import ConversationManager from "./components/messages/ConversationManager";

function renderReactComponents() {
  const components = {
    AssistantPaymentRequestAcceptPage: <AssistantPaymentRequestAcceptPage />,
    BookingCalendarPage: <BookingCalendarPage />,
    CalendarPage: <CalendarPage />,
    ClientsPage: <ClientsPage />,
    ConfirmPromosAppWithFlash: <ConfirmPromosAppWithFlash />,
    ConversationsTable: <ConversationsTable />,
    CreateAccountPage: <CreateAccountPage />,
    DashboardAppWithFlash: <DashboardAppWithFlash />,
    EmailVerifier: <EmailVerifier />,
    IntegrationsPage: <IntegrationsPage />,
    LandingPage: <LandingPage />,
    LaunchPageAppWithFlash: <LaunchPageAppWithFlash />,
    MyListsPage: <MyListsPage />,
    MarketplacePageWithFlash: <MarketplacePageWithFlash />,
    MyBooksPageWithFlash: <MyBooksPageWithFlash />,
    PaymentInfoPage: <PaymentInfoPage />,
    PenNamesAppWithFlash: <PenNamesAppWithFlash />,
    ProfilePage: <ProfilePage />,
    TermsOfService: <TermsOfService />,
    ReservationPage: <ReservationPage />,
    ResetPassword: <ResetPassword />,
    SignInPage: <SignInPage />,
  };

  const components_by_klass = {
    ConversationManager: <ConversationManager />,
  };

  for (let compId in components) {
    let rootEl = document.getElementById(compId);
    if (rootEl) {
      let props = $(rootEl).data();
      let componentWithProps = React.cloneElement(components[compId], props);
      ReactDOM.render(componentWithProps, rootEl);
    }
  }

  for (let componentKlass in components_by_klass) {
    let els = document.getElementsByClassName(componentKlass);

    if (els.length > 0) {
      for (let i = 0; i < els.length; i++) {
        let el = els[i];
        let props = $(el).data();
        let componentWithProps = React.cloneElement(
          components_by_klass[componentKlass],
          props
        );
        ReactDOM.render(componentWithProps, el);
      }
    }
  }
}

document.addEventListener("DOMContentLoaded", () => {
  renderReactComponents();
});
