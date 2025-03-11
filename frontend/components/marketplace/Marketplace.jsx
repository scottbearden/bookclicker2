import React from 'react';
import PageTitle from '../PageTitle';
import ListsApi from '../../api/ListsApi';
import SortToggleManager from '../../ext/SortToggleManager';
import MarketplaceSearch from './MarketplaceSearch';
import MarketplaceResults from './MarketplaceResults';
import MarketplacePaginationLinks from './MarketplacePaginationLinks';
import MarketplaceDateFilter from './MarketplaceDateFilter';
import { Redirect } from 'react-router';
import GenreSelect from '../GenreSelect';
import queryString from 'query-string';

const MarketplaceSortFields = { 
  open_rate: "-",
  click_rate: "-", 
  active_member_count_delimited: "-", 
  adopted_pen_name: "", 
  solo_price: "",
  feature_price: "",
  mention_price: "",
  Platform: ""
}

export default class Marketplace extends React.Component {
  
  constructor(props) {
    super(props);
    const qs = queryString.parse(location.search);
    this.state = { 
      search: qs.search, 
      favorites: qs.favorites,
      start_date: qs.start_date,
      end_date: qs.end_date,
      sort: new SortToggleManager(qs.sort, MarketplaceSortFields),
      genreIds: qs.genreIds,
      page: qs.page,
      pagination: {},
      results: [],
      my_pen_names: [],
      list_ratings: {}
    }
  }
  
  updateGenres(genres) {
    let genreIds = genres.map(genre => { return genre.value })
    if (genreIds.length > 6) {
      this.setState({genreSelectWarning: 'You may select up to 6 genres'})
    } else {
      this.setState({genreIds: (genreIds.length ? genreIds.join("-") : undefined), page: undefined, genreSelectWarning: null}, function() {
        this.fetchResults()
      });
    }
  }
  
  updateRating(list_rating) {
    let { list_ratings } = this.state
    list_ratings[list_rating.list_id] = list_rating;
    this.setState({list_ratings: list_ratings})
  }
  
  selectedGenres() {
    if (this.state.genreIds) {
      return this.state.genreIds.split("-").map(genreId => {
        return BookclickerStaticData.allGenres.find(genre => {
          return genre.value == genreId;
        })
      }).filter(genre => { return !!genre })
    } else {
      return [];
    }
  }
  
  updateSort(field, event) {
    const { sort } = this.state;
    sort.toggle(field)
    this.setState({sort, page: undefined}, function() {
      this.fetchResults();
    });
  }
  
  updateSearch(search) {
    this.setState({search, page: undefined}, function() {
      this.fetchResults();
    });
  }
  
  updatePage(page) {
    this.setState({page: page}, function() {
      this.fetchResults();
    });
  }
  
  updateFavorites() {
    let favorites = this.state.favorites ? undefined : true;
    this.setState({favorites, page: undefined}, function() {
      this.fetchResults()
    })
    
  }
  
  updateDate(update) {
    update.page = undefined;
    this.setState(update, function() {
      this.fetchResults()
    })
  }
  
  componentDidMount() {
    this.fetchResults()
  }
  
  componentDidUpdate() {
    $('.amazon-verified-link').tooltip({html: true, position: 'top'})
  }
  
  fetchResults() {
    this.setState({loading: true}, function() {
      ListsApi.getLists(this.currentSearchFilters(), this.props.preselected_book_id).then(res => {
        this.setState({loading: false, results: res.lists, list_ratings: res.list_ratings, pagination: res.pagination, my_pen_names: res.my_pen_names})
      }, err => {
        this.setState({loading: false})
      })
    })
  }
  
  currentSearchFilters() {
    let { search, genreIds, sort, page, favorites, start_date, end_date } = this.state;
    sort = sort.asQueryString() ? sort.asQueryString() : undefined;
    let queryStr = queryString.stringify({ search, genreIds, sort, page, favorites, start_date, end_date });
    return queryStr;
  }
  
  render() {
    if (location.search.slice(1) != this.currentSearchFilters()) {
      let newPath = document.location.pathname + "?" + this.currentSearchFilters();
      return <Redirect to={newPath} />
    }
    
    let title = 'Market Place';
    let subtitles = ['Browse & book promos for your launch'];
    
    if (this.props.viaLaunchPage) {
      title = "Buy Promos for this Launch";
      subtitles = [];
    }
    
    return (
      <div id="marketplace">
        <PageTitle title={title} subtitles={subtitles} />
        <MarketplaceSearch 
          search={this.state.search}
          changeHandler={this.updateSearch.bind(this)}/>
        <div className="marketplace-genre-container">
          <GenreSelect 
            genresSelected={this.selectedGenres()} 
            genreSelectWarning={this.state.genreSelectWarning}
            changeHandler={this.updateGenres.bind(this)}
            placeholder={"Filter by genre"}
            header={"Search by Genre"}
            genresOptions={BookclickerStaticData.allGenres}/>
          
          <div className="space1">&nbsp;</div>
          
          <MarketplaceDateFilter
            is_mobile={this.props.is_mobile}
            start_date={this.state.start_date}
            end_date={this.state.end_date}
            updateDate={this.updateDate.bind(this)} />
        </div>
        <div className="marketplace-pre-results">
          <div className="marketplace-pre-results-item">
            <MarketplacePaginationLinks
              links={this.state.pagination}
              changeHandler={this.updatePage.bind(this)}/>
          </div>
        </div>
        <MarketplaceResults 
          loading={this.state.loading}
          sort={this.state.sort} 
          start_date={this.state.start_date}
          favorites={this.state.favorites}
          sortHandler={this.updateSort.bind(this)}
          updateRating={this.updateRating.bind(this)}
          updateFavorites={this.updateFavorites.bind(this)}
          results={this.state.results}
          my_pen_names={this.state.my_pen_names}
          preselected_book_id={this.props.preselected_book_id}
          listRatings={this.state.list_ratings}/>
        <MarketplacePaginationLinks
          links={this.state.pagination}
          changeHandler={this.updatePage.bind(this)}/>
      </div>
    )
  }
}
