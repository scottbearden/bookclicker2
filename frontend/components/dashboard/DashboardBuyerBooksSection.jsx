import React from 'react';

export default class DashboardBuyerBooksSection extends React.Component {
  
  constructor(props) {
    super(props);
  }


  activeBooks() {
    let result = [];
    if (!this.props.books.length) {
      return (
        <tr className="no-text-shadow"><td className="no-books">You have no active books</td></tr>
      )
    }
    this.props.books.forEach((book, idx) => {
      result.push(
        <tr key={idx}>
          <td className="no-text-shadow name-only">{book.title}</td>
          <td className="no-text-shadow stat"></td>
          <td className="no-text-shadow stat"></td>
          <td className="no-text-shadow stat"></td>
          <td className="launch-link">
            <a href={'/my_books/' + book.id + "/launch"} className="bclick-button bclick-hollow-robin-egg-blue-button">
              <span className="not-phone">LAUNCH PAGE</span>
              <span className="phone">STATS</span>
            </a>
          </td>
        </tr>

      )

      result.push(<tr key={idx.toString() + "-space"} className="space-tr"></tr> )
    })
    return result;
  }


  render() {
    return (
      <div className="dashboard-activity-section">
        <div className="dashboard-activity-section-header">
          Active Books
        </div>
        <table className="dashboard-activity-table">
          <tbody>
            {this.activeBooks()}
          </tbody>
        </table>

      
      </div>
    )
  }

}
