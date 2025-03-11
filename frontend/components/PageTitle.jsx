import React from 'react';
export default class PageTitle extends React.Component {
  constructor(props) {
    super(props);
    this.state = {};
  }
  
  render() {
    
    let title = (
      <div className="page-title-title">
        {this.props.title}
      </div>
    );
    let subtitles = this.props.subtitles.map((subtitle, idx) => (
      <div className="page-title-subtitle" key={idx}>
        {subtitle}
      </div>
    ));
    
    let howItWorksText = (
      <div className="how-it-works-text">
        <p className="desktop">
          Bookclicker.com puts the power to launch in the hands of authors.<br/>
          Newsletters are the most targeted and engaged audiences for launching a book.<br/> 
          We believe that having a one stop shop for author newsletters and newsletter services with proven track records in our industry, will help you, the author, succeed.
        </p>
        <p className="not-desktop">
          Bookclicker.com puts the power to launch in the hands of authors.
          Newsletters are the most targeted and engaged audiences for launching a book. 
          We believe that having a one stop shop for author newsletters and newsletter services with proven track records in our industry, will help you, the author, succeed.
        </p>
      </div>
    )
    if (!this.props.isLanding) {
      howItWorksText = "";
    }
    
    let subtitleClass = "n-subtitles-" + subtitles.length;
    if (this.props.isLanding) {
      subtitleClass += " with-how-it-works-text";
    }
    
    return (
      <div className={"page-title-container " +  subtitleClass}>
        <div className="page-title">
          {title}
          {subtitles}
          {howItWorksText}
        </div>
      </div>
    )
    
  }
  
}
