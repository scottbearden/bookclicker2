import React from 'react';
import ReactDOMServer from 'react-dom/server';

const withFlash = (WrappedComponent) => {
  // ...and returns another component...
  return class extends React.Component {
    constructor(props) {
      super(props);
      this.state = { flash: this.props.flash, flashType: this.props.flash_type };
    }

    setFlash(flash, flashType) {
      this.setState({flash, flashType});
    }
  
    flashMessage() {
      let result = "";
      if (this.state.flash) {
        let alertCssClass = BookclickerStaticData.alertCssClasses[this.state.flashType] || "";
        var modalHtml = ReactDOMServer.renderToStaticMarkup(
          <div className={"flash-messages alert fade in " + alertCssClass}>
            <div className="flash-messages-content">
              <div 
                className="flash-message" 
                dangerouslySetInnerHTML={{__html: this.state.flash}}>
              </div>
            </div>
          </div>
        );
        var $modal = $('#reusableModal');
        $modal.find('.modal-body').html(modalHtml);
        $modal.modal()
      }
      return result;
    }

    render() {
      return (
        <WrappedComponent 
          {...this.props} 
          setFlash={this.setFlash.bind(this)}
          flashMessage={this.flashMessage.bind(this)} />);
    }
  };
}

export default withFlash;