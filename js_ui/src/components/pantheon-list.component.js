import React, {Component} from 'react';
import axios from 'axios';

export default class PantheonList extends Component {
	constructor(props) {
        super(props);
        this.state = {pantheon: []};
		this.pantheonList = this.pantheonList.bind(this);
    }

	componentDidMount() {
        axios.get('http://localhost:4000/api/pantheon')
            .then(response => {
                this.setState({ pantheon: response.data });
            })
            .catch(function (error){
                console.log(error);
            })
    }

	pantheonList() {
		console.log(this.state.pantheon)
		console.log(typeof this.state.pantheon)

		if (Object.keys(this.state.pantheon).length > 0) {
			return this.state.pantheon.data.map(function(curr, i){
				return <tr>
					<td>{curr.uniquename}</td>
					<td>{curr.name}</td>
					<td>{curr.birthdate}</td>
					<td>{curr.interests}</td>
				</tr>
			})
		}
	}

    render() {
        return (
            <div>
                <p>Meet the Pantheon</p>
				<br/>
				<table className="table table-striped" style={{ marginTop: 20 }} >
					<thead>
						<tr>
							<th>uniquename</th>
							<th>name</th>
							<th>birthdate</th>
							<th>interests</th>
						</tr>
					</thead>
					<tbody>
						{ this.pantheonList() }
					</tbody>
				</table>
            </div>
        )
    }
}
