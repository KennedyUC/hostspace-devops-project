import React, { useEffect, useState } from "react";
import $ from "jquery";

export const AllStudentsPage = ()=>{
    const [sdata,setsdata] = useState([])

    useEffect(()=>{
    const getStudent= async()=>{
        const reqOptions ={
            method:'GET',
            headers:{
                'Content-Type':'application/json'
            },
        }

        const url = `${process.env.REACT_APP_TEACHER_URL}/teacher/allstudents`
        const response = await fetch(url, reqOptions)

        const data = await response.json()

        if(!response.ok){
            console.log({"error":data.detail})
        }
        else{
            setsdata(data)
        }
    }
    getStudent()
},[])

$("#markssearch").on("keyup", function() {
    var value = $(this).val().toLowerCase();
    $("#markstable tr").filter(function() {
        if (value){
            return $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1)
            }
            else{
                return false
            }
    });
});

    return(
        <>
           <h3 style={{marginLeft:"280px",fontWeight:600}} className="">Progress</h3>
        <div className="container mt-5">
        <div className="row">
                <div className="col-8 offset-2 mb-3">
                <form class="d-flex" role="search">
                    <input id="markssearch" class="form-control me-2 border border-dark " type="search" placeholder="Search" aria-label="Search" />
                    <button class="btn btn-outline-success" type="submit">Search</button>
                </form>
                </div>
            </div>
            <div className="row">
                <div className="col-8 offset-2">
                <table id="markstable" class="table table-dark table-hover shadow-lg">
                    <thead>
                            <tr>
                            <th scope="col">Sno</th>
                            <th scope="col">firstname</th>
                            <th scope="col">lastname</th>
                            <th scope="col">email</th>
                            <th scope="col">parentname</th>
                            <th scope="col">date_of_birth</th>
                            </tr>
                        </thead>
                        <tbody>
                                {sdata.map(e=>{
                                    return(
                                        <tr key={e.id}>
                                        <th scope="col">{e.id}</th>
                                        <td>{e.firstname}</td>
                                        <td>{e.lastname}</td>
                                        <td>{e.email}</td>
                                        <td>{e.parentname}</td>
                                        <td>{e.date_of_birth}</td>
                                        </tr> 
                                    )
                                })}
                        </tbody>
                    </table> 
                </div>
            </div>
        </div> 
        </>
    )
}