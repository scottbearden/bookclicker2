import React from 'react';
import Select from 'react-select';
export default class GenreSelect extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = {};
  }
  
  genresSelected() {
    return this.props.genresSelected.map(genre => {
      return { value: (genre.id || genre.value), label: (genre.genre || genre.label) }
    })
  }
  
  render() {
    return (
      <div className="genre-select-wrapper">
        <label className="marketplace-filter-header">{this.props.header || 'Genres'}</label>
        
        <div className="genre-select-warning"><span>{this.props.genreSelectWarning}</span></div>
        <Select 
          multi={true}
          clearable={true}
          value={this.genresSelected()}
          placeholder={this.props.placeholder || "Select genres"}
          options={this.props.genresOptions}
          id="list-genre-select" 
          onChange={this.props.changeHandler}/>
          
      </div>
    )
  }
    
}
