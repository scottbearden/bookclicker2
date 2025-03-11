import React from "react";
import { Link } from "react-router-dom";
import MyListsApi from "../../api/MyListsApi";
import PriceInput from "./PriceInput";
import GenreSelect from "../GenreSelect";
import InventoryInput from "./InventoryInput";
import PageTitle from "../PageTitle";
import moment from "moment";
import { radioCheckBoxes, grabCsrfToken, pick, hex } from "../../ext/functions";

export default class MyListsShow extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      inventories_scaffolded: {},
      listId: this.props.match.params.id,
      genres: [],
      cutoff_date: null,
      genreSelectWarning: null,
      allowedSaveHash: null,
      solo_price: null,
      solo_is_swap_only: 0,
      feature_price: null,
      feature_is_swap_only: 0,
      mention_price: null,
      mention_is_swap_only: 0,
    };
  }

  componentDidMount() {
    MyListsApi.getMyList(this.state.listId).then((listAttrs) => {
      if (listAttrs.cutoff_date) {
        listAttrs.cutoff_date_moment = moment(listAttrs.cutoff_date);
      }
      this.setState(listAttrs);
    });
  }

  componentDidUpdate(prevProps) {
    if (this.refs.cutoff_date_input) {
      this.refs.cutoff_date_input.defaultValue = "";
    }
  }

  dateCutoffInput() {
    return (
      <input
        type="date"
        className={
          "form-control date-input" +
          (this.props.is_mobile ? " mobile-device" : "")
        }
        placeholder={!this.state.cutoff_date ? "select a date" : null}
        ref="cutoff_date_input"
        value={this.state.cutoff_date || ""}
        onChange={this.cutoffDateChangeHandlerWithString.bind(this, false)}
        onBlur={this.cutoffDateChangeHandlerWithString.bind(this, "persist")}
      />
    );
  }

  cutoffDateChangeHandlerWithMoment(cutoff_date_moment) {
    let cutoff_date = cutoff_date_moment
      ? cutoff_date_moment.format("YYYY-MM-DD")
      : null;
    this.cutoffDateSave(cutoff_date, cutoff_date_moment);
  }

  cutoffDateChangeHandlerWithString(persist, event) {
    let cutoff_date = event.target ? event.target.value : null;
    let cutoff_date_moment = cutoff_date ? moment(cutoff_date) : null;
    if (persist) {
      this.cutoffDateSave(cutoff_date, cutoff_date_moment);
    } else {
      this.setState({ cutoff_date, cutoff_date_moment });
    }
  }

  cutoffDateSave(cutoff_date, cutoff_date_moment) {
    this.setState(
      { cutoff_date, cutoff_date_moment, cutoff_date_error: null },
      function () {
        MyListsApi.updateCutoffDate(
          this.state.listId,
          this.state.cutoff_date
        ).then(
          (res) => {
            let cutoff_date = res.cutoff_date;
            let cutoff_date_moment = cutoff_date ? moment(cutoff_date) : null;
            this.setState({
              cutoff_date,
              cutoff_date_moment,
              cutoff_date_error: null,
            });
          },
          (errRes) => {
            let cutoff_date_was =
              errRes && errRes.responseJSON
                ? errRes.responseJSON.cutoff_date
                : null;
            let cutoff_date_moment_was = cutoff_date_was
              ? moment(cutoff_date_was)
              : null;
            let cutoff_date_error =
              (errRes && errRes.responseJSON && errRes.responseJSON.message) ||
              "Date failed to save";
            this.setState({
              cutoff_date: cutoff_date_was,
              cutoff_date_moment: cutoff_date_moment_was,
              cutoff_date_error,
            });
          }
        );
      }
    );
  }

  allowedChangeEvent(ev, inv_type) {
    if (!ev) return false;
    if (ev.dataset && ev.dataset.inv_type == inv_type) return true;
    if (ev.type == "readystatechange") return true;
    let $wrapper = $(ev.target).closest(".inventory-day-box");
    return $wrapper.length && $wrapper.data("inv_type") == inv_type;
  }

  handleSoloFeatureChange(inv_type, day, event) {
    if (this.allowedChangeEvent(event, inv_type)) {
      const { inventories_scaffolded } = this.state;
      inventories_scaffolded[inv_type][day] = event.target.checked ? 1 : 0;

      if (event.target.checked) {
        if (inv_type == "solo") {
          inventories_scaffolded["feature"][day] = 0;
          inventories_scaffolded["mention"][day] = 0;
        } else if (inv_type == "feature") {
          inventories_scaffolded["solo"][day] = 0;
        }
      }
      this.setState({ inventories_scaffolded }, () => {
        this.throttleSaveAll();
      });
    }
  }

  handleMentionsChange(inv_type, day, value, valueString, eventTarget) {
    if (this.allowedChangeEvent(eventTarget, inv_type)) {
      const { inventories_scaffolded } = this.state;
      inventories_scaffolded[inv_type][day] = value;
      if (value) {
        inventories_scaffolded["solo"][day] = 0;
      }
      this.setState({ inventories_scaffolded }, () => {
        this.throttleSaveAll();
      });
    }
  }

  handleGenreChange(genres) {
    if (genres.length > 6) {
      this.setState({
        genreSelectWarning: "You may select a maximum of 6 genres",
      });
    } else {
      this.setState({ genres: genres, genreSelectWarning: null }, () => {
        this.throttleSaveAll();
      });
    }
  }

  handlePriceChange(priceType, event) {
    const state = this.state;
    state[priceType + "_price"] = event.target.value;
    state[priceType + "_is_swap_only"] = 0;
    this.setState(state, this.throttleSaveAll.bind(this));
  }

  handlePriceClear(priceType) {
    let prices = pick(this.state, [
      "solo_price",
      "feature_price",
      "mention_price",
    ]);
    prices[priceType + "_price"] = "100";
    this.setState(prices, () => {
      prices[priceType + "_price"] = null;
      this.setState(prices, this.throttleSaveAll.bind(this));
    });
  }

  toggleSwapOnly(priceType, event) {
    const state = this.state;
    state[priceType + "_is_swap_only"] = state[priceType + "_is_swap_only"]
      ? 0
      : 1;
    console.log(state);
    this.setState(state, () => {
      this.handlePriceClear(priceType);
    });
  }

  throttleSaveAll() {
    let delay = 700;
    let allowedSaveHash = hex(10);
    this.setState({ allowedSaveHash, lastChangeAt: Date.now() }, () => {
      var that = this;
      setTimeout(function () {
        if (that.state.allowedSaveHash !== allowedSaveHash) {
          console.log("died");
          return null;
        } else if (Date.now() - that.state.lastChangeAt >= delay) {
          that.executeSave();
        } else {
          console.log("recursive");
          that.throttleSaveAll();
        }
      }, delay);
    });
  }

  executeSave() {
    MyListsApi.updateInventoriesGenresPrices(
      this.state.listId,
      this.state.inventories_scaffolded,
      this.state.genres,
      pick(this.state, [
        "solo_price",
        "feature_price",
        "mention_price",
        "solo_is_swap_only",
        "feature_is_swap_only",
        "mention_is_swap_only",
      ])
    ).then(
      (res) => {
        console.log("saved");
      },
      (res) => {
        console.log("save failed");
      }
    );
  }

  changeAuthorEmail(event) {
    let allowedSaveHash = hex(10);
    this.setState({
      book_owner_email: event.target ? event.target.value : null,
      lastChangeAt: Date.now(),
      allowedSaveHash,
    });
    this.throttleSave(allowedSaveHash);
  }

  render() {
    return (
      <div className="my-lists-show">
        <PageTitle
          title="My Mailing Lists"
          subtitles={["Set your inventory"]}
        />
        <div className="my-lists-show-container">
          <div className="my-lists-show-content">
            <div className="my-lists-show-header">
              <div className="my-lists-show-name">
                {this.state.adopted_pen_name}
              </div>
            </div>
            <hr />
            <div className="my-lists-show-form-container">
              <form
                method="POST"
                onSubmit={(e) => {
                  e.preventDefault();
                }}
              >
                <div className="my-lists-show-set-up">
                  <div className="my-lists-show-prices">
                    <div className="my-lists-show-inventory-caption">
                      Set your pricing for this list
                    </div>

                    <PriceInput
                      priceType="solo"
                      price={this.state.solo_price}
                      is_swap_only={this.state.solo_is_swap_only}
                      changeHandler={this.handlePriceChange.bind(this, "solo")}
                      toggleSwapOnly={this.toggleSwapOnly.bind(this, "solo")}
                      clearHandler={this.handlePriceClear.bind(this, "solo")}
                    />

                    <PriceInput
                      priceType="feature"
                      price={this.state.feature_price}
                      is_swap_only={this.state.feature_is_swap_only}
                      changeHandler={this.handlePriceChange.bind(
                        this,
                        "feature"
                      )}
                      toggleSwapOnly={this.toggleSwapOnly.bind(this, "feature")}
                      clearHandler={this.handlePriceClear.bind(this, "feature")}
                    />

                    <PriceInput
                      priceType="mention"
                      price={this.state.mention_price}
                      is_swap_only={this.state.mention_is_swap_only}
                      changeHandler={this.handlePriceChange.bind(
                        this,
                        "mention"
                      )}
                      toggleSwapOnly={this.toggleSwapOnly.bind(this, "mention")}
                      clearHandler={this.handlePriceClear.bind(this, "mention")}
                    />
                  </div>

                  <div className="my-lists-show-genres">
                    <GenreSelect
                      genresSelected={this.state.genres}
                      genreSelectWarning={this.state.genreSelectWarning}
                      changeHandler={this.handleGenreChange.bind(this)}
                      genresOptions={BookclickerStaticData.allGenres.filter(
                        (genre) => {
                          return !genre.search_only;
                        }
                      )}
                    />
                  </div>

                  <div className="my-lists-show-cutoff-date">
                    <label>{"Accept Bookings Until"}</label>
                    <div className="genre-select-warning"></div>
                    <div className="my-lists-show-cutoff-date-input">
                      {this.dateCutoffInput()}
                    </div>
                    <div className="my-lists-show-cutoff-date-error">
                      {this.state.cutoff_date_error}
                    </div>
                  </div>

                  <div className="my-lists-show-inventory">
                    <div className="my-lists-show-inventory-caption">
                      You can always change specific days in your sales
                      calendar.
                    </div>
                    <InventoryInput
                      isMobile={this.props.is_mobile}
                      inventories={this.state.inventories_scaffolded}
                      soloFeatureChangeHandler={this.handleSoloFeatureChange.bind(
                        this
                      )}
                      mentionsChangeHandler={this.handleMentionsChange.bind(
                        this
                      )}
                    />
                  </div>

                  <div className="my-lists-show-submit">
                    <Link
                      role="button"
                      to={"/my_lists"}
                      className="bclick-button bclick-solid-robin-egg-blue-button bclick-no-text-transform-button"
                    >
                      Save
                    </Link>
                  </div>
                </div>
              </form>
            </div>
          </div>
        </div>
      </div>
    );
  }
}
