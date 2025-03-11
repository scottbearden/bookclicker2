import React from "react";
import MyBooksApi from "../../api/MyBooksApi";
import PenNamesApi from "../../api/PenNamesApi";
import AmazonProductsApi from "../../api/AmazonProductsApi";
import BookLinks from "./BookLinks";
import { grabCsrfToken, setFileUpload, hex } from "../../ext/functions";
import queryString from "query-string";
import Select from "react-select";
import moment from "moment";
import GooglePlayBooksApi from "../../api/GooglePlayBooksApi";

export default class MyBooksShow extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      allowedSaveHash: null,
      book: this.initBook(),
      pen_names: this.initPenNames(),
    };
  }

  defaultPenNameId() {
    const qs = queryString.parse(location.search);
    return qs.pen_name_id ? parseInt(qs.pen_name_id) : null;
  }

  prepareBookJson(book) {
    if (book.launch_date) {
      book.launch_date_moment = moment(book.launch_date);
    }
    return book;
  }

  initBook() {
    if (this.props.isNew) {
      return {
        book_links: [
          { placeholder: "https://www.amazon.com/ ..." },
          { placeholder: "https://play.google.com/store/books/ ..." },
          { placeholder: "https://itunes.apple.com/ ..." },
        ],
        pen_name_id: this.defaultPenNameId(),
      };
    } else if (this.props.book) {
      let book = this.prepareBookJson(this.props.book);
      return book;
    } else {
      return { book_links: [] };
    }
  }

  initPenNames() {
    if (this.props.isNew) {
      return this.defaultPenNameId()
        ? [{ id: this.defaultPenNameId(), author_name: "Loading..." }]
        : [];
    } else if (this.props.book) {
      return [{ id: this.props.book.pen_name_id, author_name: "Loading..." }];
    } else {
      return [];
    }
  }

  componentDidMount() {
    if (!this.props.isNew && !this.bookHasLoaded()) {
      console.log("loading book");
      MyBooksApi.getMyBook(this.props.bookId).then((book) => {
        this.setState({ book: this.prepareBookJson(book) });
      });
    }
    PenNamesApi.getPenNamesListForBuyer().then((res) => {
      this.setState({ pen_names: res.pen_names });
    });
    setFileUpload($, this.fileUploadCallback.bind(this));
  }

  bookHasLoaded() {
    return !!this.state.book.id;
  }

  fileUploadCallback(image_url) {
    const { book } = this.state;
    book["cover_image_url"] = image_url;
    this.setState({ book: book }, this.save.bind(this));
  }

  handleChange(bookField, event) {
    const { book } = this.state;
    book[bookField] = event.target.value;
    this.setState({ book: book }, this.save.bind(this));
  }

  populateWithApi(bookLinkUrl, api) {
    if (api === "amazon_products") {
      this.populateWithAmazonProductsApi(bookLinkUrl);
    } else if (api === "google_books") {
      this.populateWithGoogleBooksApi(bookLinkUrl);
    }
  }

  populateWithAmazonProductsApi(bookLinkUrl) {
    AmazonProductsApi.getItemAttrs(bookLinkUrl).then((attrs) => {
      const { book } = this.state;
      if (attrs.title && !book.title) {
        book.title = attrs.title;
      }
      if (attrs.cover_image_url && !book.cover_image_url) {
        book.cover_image_url = attrs.cover_image_url;
      }
      if (attrs.blurb && !book.blurb) {
        book.blurb = attrs.blurb;
      }

      // Amazon takes precedence with this data and it always get used
      [
        "amazon_author",
        "review_count",
        "avg_review",
        "pub_date",
        "book_rank",
      ].forEach((attr) => {
        if (attrs[attr]) {
          book[attr] = attrs[attr];
        }
      });

      this.setState({ book }, this.save.bind(this));
    });
  }

  populateWithGoogleBooksApi(bookLinkUrl) {
    GooglePlayBooksApi.getItemAttrs(bookLinkUrl).then((attrs) => {
      if (!attrs || !attrs.volumeInfo) {
        return;
      }
      const { book } = this.state;
      if (attrs.volumeInfo.title && !book.title) {
        book.title = attrs.volumeInfo.title;
      }
      if (
        attrs.volumeInfo.imageLinks &&
        attrs.volumeInfo.imageLinks.thumbnail &&
        !book.cover_image_url
      ) {
        book.cover_image_url = attrs.volumeInfo.imageLinks.thumbnail;
      }
      if (attrs.volumeInfo.description && !book.blurb) {
        book.blurb = attrs.volumeInfo.description;
      }
      if (attrs.volumeInfo.publishedDate && !book.pub_date) {
        book.pub_date = attrs.volumeInfo.publishedDate;
      }
      if (attrs.volumeInfo.ratingsCount && !book.review_count) {
        book.review_count = attrs.volumeInfo.ratingsCount;
      }
      if (attrs.volumeInfo.averageRating && !book.avg_review) {
        book.avg_review = attrs.volumeInfo.averageRating;
      }
      this.setState({ book }, this.save.bind(this));
    });
  }

  formActionPath() {
    if (this.props.isNew) {
      return "/my_books";
    } else {
      return "/my_books/" + this.state.book.id;
    }
  }

  hiddenHttpVerbInput() {
    if (this.props.isNew) {
      return <span />;
    } else {
      return <input type="hidden" name="_method" value="PUT" />;
    }
  }

  save(graceTime = 0) {
    if (this.state.bookCurrentlySaving || !this.bookHasLoaded()) return null;

    let allowedSaveHash = hex(10);
    this.setState({ allowedSaveHash, lastChangeAt: Date.now() + graceTime });
    this.throttleSave(allowedSaveHash);
  }

  throttleSave(allowedSaveHash) {
    var that = this;
    setTimeout(function () {
      if (that.state.allowedSaveHash !== allowedSaveHash) {
        return null;
      } else if (Date.now() - that.state.lastChangeAt > 1000) {
        that._update();
      } else {
        console.log("postponing save");
        that.throttleSave(allowedSaveHash);
      }
    }, 1200);
  }

  _update() {
    this.setState({ bookCurrentlySaving: true }, function () {
      let data = this.state.book;
      data.launch_date_moment = null;
      console.log("saving....");
      console.log(data);

      MyBooksApi.update(data).then(
        (res) => {
          let book = this.prepareBookJson(res.book);
          this.setState({ bookCurrentlySaving: false, book: book });
        },
        (errRes) => {
          this.setState({ bookCurrentlySaving: false });
        }
      );
    });
  }

  handlePenNameChange(selection) {
    let { book } = this.state;
    book.pen_name_id = selection ? selection.value : null;
    this.setState({ book: book }, this.save.bind(this));
  }

  penNameOptions() {
    return this.state.pen_names.map((pen_name, idx) => {
      return { label: pen_name.author_name, value: pen_name.id };
    });
  }

  datePickerChangeHandler(val) {
    let { book } = this.state;
    book.launch_date_moment = val;
    book.launch_date = val ? val.format("YYYY-MM-DD") : null;
    this.setState({ book: book }, this.save.bind(this));
  }

  dateChangeHandler(event) {
    let { book } = this.state;
    book.launch_date = event.target.value;
    this.setState({ book: book }, this.save.bind(this));
  }

  updateBookLinks(book_links, cancelQueuedSaves = false) {
    const { book } = this.state;
    book.book_links = book_links;
    console.log(book_links);
    this.setState({ book }, function () {
      if (cancelQueuedSaves) {
        console.log("cancelling saves");
        this.setState({ allowedSaveHash: null });
      } else {
        this.save();
      }
    });
  }

  datePicker() {
    return (
      <div className="date-picker-container">
        <input
          type="date"
          value={this.state.book.launch_date || ""}
          placeholder="Select a date"
          name="book[launch_date]"
          onChange={this.dateChangeHandler.bind(this)}
          className="date-input"
        />
      </div>
    );
  }

  render() {
    return (
      <div className="my-books-show">
        <div className="my-books-show-container">
          <div className="my-books-show-content">
            <div className="my-books-show-form-container">
              <form method="POST" action={this.formActionPath()}>
                {this.hiddenHttpVerbInput()}
                <input
                  type="hidden"
                  name="authenticity_token"
                  value={grabCsrfToken($)}
                />
                <input
                  type="hidden"
                  name="cal_back"
                  value={queryString.parse(location.search).cal_back}
                />

                <div className="my-books-fields-container">
                  <div className="my-books-input">
                    <div className="my-books-input-label">Title</div>
                    <input
                      type="text"
                      name="book[title]"
                      value={this.state.book.title || ""}
                      required
                      onChange={this.handleChange.bind(this, "title")}
                      placeholder={this.state.book.title ? "" : "Book Title"}
                    />
                  </div>

                  <div className="my-books-input">
                    <div className="my-books-input-label">Pen Name</div>
                    <Select
                      type="text"
                      name="book[pen_name_id]"
                      clearable={false}
                      searchable={false}
                      options={this.penNameOptions()}
                      value={this.state.book.pen_name_id || ""}
                      required
                      onChange={this.handlePenNameChange.bind(this)}
                      placeholder={
                        this.state.book.pen_name_id ? "" : "Select Pen Name"
                      }
                    />
                  </div>

                  <div className="my-books-input">
                    <div className="my-books-input-label">Launch Date</div>
                    {this.datePicker()}
                  </div>

                  <div
                    className="my-books-input"
                    style={{ paddingBottom: "0px" }}
                  >
                    <div className="my-books-input-label">Links</div>
                  </div>

                  <BookLinks
                    isNewBook={this.props.isNew}
                    bookLinks={this.state.book.book_links}
                    triggerSave={this.save.bind(this)}
                    populateWithApi={this.populateWithApi.bind(this)}
                    propogateBookLinks={this.updateBookLinks.bind(this)}
                  />

                  <div className={"my-books-input tall"}>
                    <div className="my-books-input-label">Blurb</div>
                    <textarea
                      type="text"
                      name="book[blurb]"
                      value={this.state.book.blurb || ""}
                      onChange={this.handleChange.bind(this, "blurb")}
                      placeholder={this.state.book.blurb ? "" : "Blurb"}
                    />
                  </div>

                  <div
                    className="my-books-input half"
                    style={{ paddingBottom: "0px" }}
                  >
                    <div className="my-books-input-label">Review Count</div>
                    <input
                      type="text"
                      disabled={true}
                      value={this.state.book.review_count || ""}
                      required
                      onChange={() => {}}
                      placeholder={"Data not available"}
                    />
                  </div>

                  <div
                    className="my-books-input half"
                    style={{ paddingBottom: "0px" }}
                  >
                    <div className="my-books-input-label">Review Avg</div>
                    <input
                      type="text"
                      disabled={true}
                      value={this.state.book.avg_review || ""}
                      required
                      onChange={() => {}}
                      placeholder={"Data not available"}
                    />
                  </div>

                  <div
                    className="my-books-input half"
                    style={{ paddingBottom: "0px" }}
                  >
                    <div className="my-books-input-label">Published Date</div>
                    <input
                      type="text"
                      disabled={true}
                      value={
                        this.state.book.pub_date
                          ? moment(
                              this.state.book.pub_date,
                              "YYYY-MM-DD"
                            ).format("MMM DD, YYYY")
                          : ""
                      }
                      required
                      onChange={() => {}}
                      placeholder={"Data not available"}
                    />
                  </div>

                  <div
                    className="my-books-input half"
                    style={{ paddingBottom: "0px" }}
                  >
                    <div className="my-books-input-label">Amazon Rank</div>
                    <input
                      type="text"
                      disabled={true}
                      value={this.state.book.book_rank || ""}
                      required
                      onChange={() => {}}
                      placeholder={"Data not available"}
                    />
                  </div>

                  <div className="my-books-images">
                    <div className="my-books-images-uploading">
                      <div className="fileuploader">
                        <label
                          htmlFor="fileupload"
                          className="btn bclick-button bclick-hollow-green-button not-phone"
                        >
                          Upload Cover Image
                        </label>

                        <label
                          htmlFor="fileupload"
                          className="btn bclick-button bclick-hollow-green-button phone"
                        >
                          Add Image
                        </label>
                        <input
                          id="fileupload"
                          type="file"
                          style={{ visibility: "hidden" }}
                          className="fileinput-button"
                          name="book[cover_image]"
                        />
                        <input
                          id="book-cover-image-url"
                          className="fileinput-url"
                          type="hidden"
                          value={this.state.book.cover_image_url || ""}
                          name="book[cover_image_url]"
                        />
                      </div>

                      <div id="progress" className="progress">
                        <div className="progress-bar progress-bar-success"></div>
                      </div>

                      <div
                        className="fileuploader"
                        style={{
                          display: this.state.book.cover_image_url
                            ? "block"
                            : "none",
                        }}
                        onClick={this.fileUploadCallback.bind(this, null)}
                      >
                        <label className="btn bclick-button bclick-hollow-youtube-red-button">
                          Remove Cover Image
                        </label>
                      </div>
                    </div>

                    <div
                      className="my-books-images-img"
                      style={{
                        border: this.state.book.cover_image_url
                          ? "none"
                          : "1px solid #e9e9e9",
                      }}
                    >
                      <div
                        className="my-books-images-img-placeholder"
                        style={{ textShadow: "none" }}
                      >
                        Cover Image
                      </div>
                      <div className="fileupload-img">
                        <img src={this.state.book.cover_image_url}></img>
                      </div>
                    </div>
                  </div>

                  <div
                    className={
                      "my-books-show-submit" +
                      (this.props.isLaunchPage ? " hide" : "")
                    }
                  >
                    <div className="my-books-show-submit-button-wrapper">
                      <input
                        type="submit"
                        value="Save"
                        className="bclick-button bclick-solid-robin-egg-blue-button bclick-no-text-transform-button"
                      />
                    </div>
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
