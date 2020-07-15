import React, {Component} from 'react';
import { BrowserRouter as Router, Route, Link } from "react-router-dom";
import "bootstrap/dist/css/bootstrap.min.css";

import PantheonList from "./components/pantheon-list.component";
import Home from "./components/home.component";
import logo from "./logo.jpg"

function App() {
  return (
	  <Router>
	    <div className="App">
			<h2>A Title!</h2>

			<nav className="navbar navbar-expand-lg navbar-light bg-light">
              <a className="navbar-brand" href="https://codingthesmartway.com" target="_blank">
                <img src={logo} width="30" height="30" alt="CodingTheSmartWay.com" />
              </a>
              <Link to="/" className="navbar-brand">Home</Link>
              <div className="collpase navbar-collapse">
                <ul className="navbar-nav mr-auto">
                  <li className="navbar-item">
                    <Link to="/list" className="nav-link">AllApps</Link>
                  </li>
                </ul>
              </div>
            </nav>
            <br/>

			{/*What does exact do*/}
			<Route path="/" exact component={Home} />
			<Route path="/list" component={PantheonList} />
			{/*<Route path="/edit/:id" component={EditTodo} />*/}
			{/*<Route path="/create" component={CreateTodo} />*/}
	    </div>
	  </Router>
  );
}

export default App;
