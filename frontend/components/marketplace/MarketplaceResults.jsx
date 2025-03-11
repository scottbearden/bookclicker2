import React from 'react';
import ResultRow from './ResultRow';
import HeaderRow from './HeaderRow';

export default class MarketplaceResults extends React.Component {
  constructor(props) {
    super(props);
    this.state = {};
  }
  
  render() {
    let resultsRows = null;
    if (!this.props.results.length) {
      resultsRows = <tr><td colSpan="100%">{this.props.loading ? "loading results..." : "No Results Found"}</td></tr>;
    } else {
      resultsRows = this.props.results.map((result, idx) => {
        return (
          <ResultRow 
            attributes={result}
            myPenNames={this.props.my_pen_names} 
            key={result.id} 
            start_date={this.props.start_date}
            preselected_book_id={this.props.preselected_book_id}
            updateRating={this.props.updateRating}
            rating={this.props.listRatings[result.id] ? this.props.listRatings[result.id].rating : null} />
        )
      })
    }

    return (
      <div className="marketplace-results">
        <table className="table table-striped">
          <thead className="thead">
            <HeaderRow key="head" 
              sort={this.props.sort}
              favorites={this.props.favorites}
              updateFavorites={this.props.updateFavorites}
              sortHandler={this.props.sortHandler.bind(this)}>
            </HeaderRow>
          </thead>
          <tbody>
            {resultsRows}
          </tbody>
        </table>
      </div>
    )
  }
}
