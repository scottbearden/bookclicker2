import React from "react";

export default class MarketplaceDateFilter extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      start_date: this.props.start_date,
      end_date: this.props.end_date,
    };
  }

  clearDate(field) {
    let stateUpdate = {};
    stateUpdate[field] = "";
    this.setState(stateUpdate, () => {
      this.props.updateDate(stateUpdate);
    });
  }

  changeDateState(field, event) {
    let newState = {};
    newState[field] = event.target.value || "";
    this.setState(newState, () => {
      this.props.updateDate(newState);
    });
  }

  render() {
    return (
      <div className="genre-select-wrapper">
        <label className="marketplace-filter-header">{"Dates Available"}</label>

        <div className="date-selectors">
          <div className="date-selector left">
            <label className="small-date-selector-label">
              Available after
              <a
                style={{
                  display: this.state.start_date ? "inline-block" : "none",
                }}
                className={
                  "small-date-selector-clear" +
                  (this.props.is_mobile ? " mobile" : "")
                }
                onClick={() => this.clearDate("start_date")}
              >
                <span>{this.props.is_mobile ? "(clear)" : "clear"}</span>
              </a>
            </label>
            {this.dateSelector("start_date")}
          </div>

          <div className="date-selector right">
            <label className="small-date-selector-label">
              Available before
              <a
                style={{
                  display: this.state.end_date ? "inline-block" : "none",
                }}
                className={
                  "small-date-selector-clear" +
                  (this.props.is_mobile ? " mobile" : "")
                }
                onClick={() => this.clearDate("end_date")}
              >
                <span>{this.props.is_mobile ? "(clear)" : "clear"}</span>
              </a>
            </label>
            {this.dateSelector("end_date")}
          </div>
        </div>
      </div>
    );
  }

  dateSelector(field) {
    let placeholder =
      field === "start_date" ? "Available from" : "Available until";

    return (
      <input
        type="date"
        className="form-control"
        placeholder={!this.state[field] ? placeholder : null}
        value={this.state[field] || ""}
        onChange={(event) => this.changeDateState(field, event)}
      />
    );
  }
}
