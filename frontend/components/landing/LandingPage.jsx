
import React from 'react';
import { Redirect } from 'react-router';
import { BrowserRouter, Match, Route, Link } from 'react-router-dom';
import Slider, { Range } from 'rc-slider';
import { invertDict, scrollToHash }  from '../../ext/functions';

import PageTitle from '../PageTitle';
import Benefits from './Benefits';
import Pricing from './Pricing';
import SignUp from './SignUp';

const paths = {
  benefits: '/benefits',
  pricing: '/pricing',
  sign_up: '/sign_up'
}
const invertPaths = invertDict(paths);

const sliderPositions = {
  benefits: 0,
  pricing: 50,
  sign_up: 100
}
const invertSliderPositions = invertDict(sliderPositions);

export default class LandingPage extends React.Component {
  
  constructor(props) {
    super(props);
    let hash = document.location.hash;
    let currentPage = invertPaths[document.location.pathname] || "benefits";
    let sliderPosition = sliderPositions[currentPage];
    this.state = { 
      currentPage, sliderPosition, hash
    };
  }
  
  onSliderChange(sliderPosition) {
    let currentPage = invertSliderPositions[sliderPosition];
    this.setState({currentPage, sliderPosition});
  }
  
  componentDidMount() {
    scrollToHash(this.state.hash, $)
  }
  
  marks() {
    return {
      0: {
        style: {
          color: this.state.currentPage == 'benefits' ? 'white' : '#696969',
        },
        label: <span className='strong'>Benefits</span>
      },
      50: {
        style: {
          color: this.state.currentPage == 'pricing' ? 'white' : '#696969',
        },
        label: <span className='strong'>Pricing</span>
      },
      100: {
        style: {
          color: this.state.currentPage == 'sign_up' ? 'white' : '#696969'
        },
        label: <span className='strong'>Sign Up</span>
      }
    }
  }
  
  render() {
    let title = 'Bookclicker';
    let subtitles = [''];
    
    const { currentPage } = this.state;
    return (
      <div>
        <PageTitle title={title} subtitles={subtitles} isLanding={true} />
        <div id="landing-slider">
          <Slider min={0} 
            marks={this.marks()} 
            step={null} 
            onChange={this.onSliderChange.bind(this)} 
            value={this.state.sliderPosition} />
          <BrowserRouter>
            <div className="landing-slider-page">
              <div className="landing-slider-page-container">
              
                <Route exact path="/" >
                  <Redirect to={paths['benefits']}/>
                </Route>
            
                <Route path={paths['benefits']} render={() => (
                  currentPage == 'benefits' ?
                    <Benefits/> :
                    <Redirect to={paths[currentPage]}/>
                )}></Route>
      
                <Route path={paths['pricing']} render={() => (
                  currentPage == 'pricing' ?
                    <Pricing/> :
                    <Redirect to={paths[currentPage]}/>
                )}></Route>
      
                <Route path={paths['sign_up']} render={() => (
                  currentPage == 'sign_up' ?
                    (<SignUp/>) :
                    <Redirect to={paths[currentPage]}/>
                )}></Route>
              </div>
      
            </div>
          </BrowserRouter>
        </div>
      </div>
    )
  }
  
}

