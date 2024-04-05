import React, { useState, useEffect } from 'react';
import { NavLink } from 'react-router-dom';
import '../index.css';
import GraphicEqIcon from '@mui/icons-material/GraphicEq';
import ChevronRightIcon from '@mui/icons-material/ChevronRight';

export const DasboardPage = ()=>{
    const[picdata, setpicdata] = useState({})
    const token = localStorage.getItem("studentToken")
    useEffect(()=>{
        const fetchUser = async()=>{
            const requestOptions = {
                method:"POST",
                headers:{
                    "Content-Type":"application/json",
                    Authorization: "Bearer " + localStorage.getItem("studentToken")
                }
            }
            const url = `${process.env.REACT_APP_STUDENT_URL}/token/decoder`
            const response = await fetch(url, requestOptions)
            const data = await response.json()
            if(!response.ok){
                console.log({"error":data.detail})
            }
            else{
                console.log(data)
                setpicdata(data)
            }
        }
        fetchUser();
    },[token])

    return(
        <div>
            <div className='dashmaindiv'>
            <div className='container' style={{marginLeft:"100px"}}>
            <div className='dashboardsection'>
                    <div className='row'>
                        <div className='col-4 p-4 ppcol'>
                            <div className='profilediv'>
                                <img className='ppic shadow' src='assets/images/profile1.jpg' alt='profilejpg'/>
                            </div>
                            <div className='ppictxt'>
                                <div>{picdata.firstname}&nbsp;{picdata.lastname}</div>
                            </div>
                        </div>
                        <div className='col-8'>
                                <div class="h-100 p-5 text-bg-dark jumb1">
                                    <div className='text-end'><GraphicEqIcon/></div>
                                        <h2>Profile Information</h2>
                                        <p>Hi, my name is <span className='fw-bold'>{picdata.firstname}&nbsp;{picdata.lastname}</span> and my mail id is <span className='fw-bold'>{picdata["email"]}</span>. i was born on </p>
                                        <p><span className='fw-bold'>{picdata["date_of_birth"]}</span> and I live in <span className='fw-bold'>{picdata["address"]}</span> and i am happy to join STL family</p>
                                        
                                        
                                        <button class="btn btn-outline-danger" type="button"><NavLink style={{textDecoration:"none",color:"white"}} to="/status">View Analytics <span><ChevronRightIcon/></span></NavLink></button>
                                </div>
                        </div>
                    </div>
    
                    </div>
                </div>
                </div>
            </div>
       
    )
}